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

// 处理每一个分组
config.outbounds.forEach(i => {
  if ("outbounds" in i && i.outbounds.includes("{all}")) {
    i.outbounds = i.outbounds.filter(item => item !== "{all}");

    // 处理多个过滤器
    if ("filter" in i && Array.isArray(i.filter) && i.filter.length > 0) {
      let matched = getTags(proxies); // 默认包含所有

      for (const f of i.filter) {
        const keywordList = Array.isArray(f.keywords) ? f.keywords : [];
        const keywordRegexList = keywordList.map(k => {
          try {
            return new RegExp(k, "i");
          } catch (e) {
            return null;
          }
        }).filter(Boolean);

        const currentMatched = getTags(proxies, keywordRegexList);

        if (f.action === "include") {
          matched = matched.filter(tag => currentMatched.includes(tag));
        } else if (f.action === "exclude") {
          matched = matched.filter(tag => !currentMatched.includes(tag));
        }
      }

      i.outbounds.push(...matched);
      delete i.filter;
    }
  }
});

// 添加代理节点
config.outbounds.push(...proxies);

// 为空组补一个兼容节点
config.outbounds.forEach(i => {
  if (Array.isArray(i.outbounds) && i.outbounds.length === 0) {
    if (!compatible) {
      config.outbounds.push(compatible_outbound);
      compatible = true;
    }
    i.outbounds.push(compatible_outbound.tag);
  }
});

$content = JSON.stringify(config, null, 2);

// 获取匹配的 tag 列表
function getTags(proxies, regexList) {
  return proxies
    .filter(p => {
      if (!regexList || regexList.length === 0) return true;
      return regexList.some(regex => regex.test(p.tag));
    })
    .map(p => p.tag);
}
