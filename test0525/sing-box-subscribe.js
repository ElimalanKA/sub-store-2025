const { type, name } = $arguments;

const compatible_outbound = {
  tag: 'COMPATIBLE',
  type: 'block',
};

let compatible;
let config = JSON.parse($files[0]);

let proxies = await produceArtifact({
  name,
  type: /^1$|col/i.test(type) ? 'collection' : 'subscription',
  platform: 'sing-box',
  produceType: 'internal',
});

config.outbounds.forEach(i => {
  if ("outbounds" in i && i.outbounds.includes("{all}")) {
    // 模拟所有节点
    const allValues = ["jp", "tw", "sg", "us", "dual-stack"];
    i.outbounds = i.outbounds.filter(item => item !== "{all}");
    i.outbounds.push(...allValues);

    // 处理 include/exclude filter
    if (
      "filter" in i &&
      Array.isArray(i.filter) &&
      i.filter.length > 0 &&
      i.filter[0].keywords &&
      i.filter[0].keywords.length > 0
    ) {
      const f = i.filter[0];
      const keyword = f.keywords[0];
      const p = getTags(proxies, keyword);

      if (f.action === "include") {
        i.outbounds.push(...p);
      } else if (f.action === "exclude") {
        const all = getTags(proxies);
        i.outbounds.push(...all.filter(item => !p.includes(item)));
      }

      delete i.filter;
    }
  }
});

// 加入 proxies 节点
config.outbounds.push(...proxies);

// 为空的组补一个兼容节点
config.outbounds.forEach(outbound => {
  if (Array.isArray(outbound.outbounds) && outbound.outbounds.length === 0) {
    if (!compatible) {
      config.outbounds.push(compatible_outbound);
      compatible = true;
    }
    outbound.outbounds.push(compatible_outbound.tag);
  }
});

$content = JSON.stringify(config, null, 2);

// 工具函数：从 proxies 中取出匹配的 tag
function getTags(proxies, regex) {
  if (regex) {
    try {
      regex = new RegExp(regex);
    } catch (e) {
      return []; // 如果正则错误，返回空数组
    }
  }
  return (regex ? proxies.filter(p => regex.test(p.tag)) : proxies).map(p => p.tag);
}
