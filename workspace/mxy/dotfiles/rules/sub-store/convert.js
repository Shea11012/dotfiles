/*
- full: 启用完整配置，用于纯内核启动(默认false)
 - loadbalance: 负载均衡
 */

const inArg = typeof $arguments !== "undefined" ? $arguments : {};
const full = parseBool(inArg.full) || false;
const loadBalance = parseBool(inArg.loadbalance) || false;

const ruleProviders = {
  "custom-direct": {
    type: "http",
    behavior: "classical",
    interval: 86400,
    url: "http://raw.githubusercontent.com/Shea11012/dotfiles/main/workspace/mxy/dotfiles/clash/custom-direct.yaml",
    path: "./ruleset/custom-direct.yaml",
  },
  "custom-proxy": {
    type: "http",
    behavior: "classical",
    interval: 86400,
    url: "https://gist.github.com/Shea11012/2b2a2659468c2c29e0baae906016b31c/raw/custom-proxy.yaml",
    path: "./ruleset/custom-proxy.yaml",
  },
};

const rules = [
  "GEOSITE,category-ads-all,REJECT",
  "RULE-SET,custom-direct,DIRECT",
  "RULE-SET,custom-proxy,PROXY",

  // 内网流量
  "GEOSITE,private,DIRECT",
  "GEOIP,private,DIRECT,no-resolve",

  // 国内流量
  "GEOSITE,geolocation-cn,DIRECT",
  "GEOSITE,category-games@cn,DIRECT",
  "GEOSITE,steam@cn,DIRECT",
  "GEOSITE,microsoft@cn,DIRECT",
  "GEOIP,cn,DIRECT,no-resolve",

  // 国外流量
  "GEOSITE,category-ai-!cn,AI",
  "GEOSITE,geolocation-!cn,PROXY",
  "GEOIP,google,PROXY,no-resolve",
  "GEOIP,cloudflare,PROXY,no-resolve",
  "GEOIP,telegram,TG,no-resolve",

  "MATCH,default",
];

const sniffConfig = {
  enable: true,
  "force-dns-mapping": true,
  "parse-pure-ip": true,
  "override-destination": false,
  sniff: {
    HTTP: {
      ports: [80, 443],
    },
    TLS: {
      ports: [443],
    },
  },
  "skip-domain": ["Mijia Cloud", "dlg.io.mi.com", "+.push.apple.com"],
};

const tunConfig = {
  enable: true,
  stack: "mixed",
  "auto-route": true,
  "auto-detect-interfacce": true,
  "auto-redirect": true,
};

const direct = ["https://119.29.29.29/dns-query", "https://223.5.5.5/dns-query"]

const dnsConfig = {
  enable: true,
  "prefer-h3": true,
  "enhanced-mode": "fake-ip",
  "fake-ip-filter": ["geosite:connectivity-check", "geosite:private","geosite:cn","+.miwifi.com"],
  "fake-ip-range": "198.18.0.1/16",
  // 用于解析dns域名
  "default-nameserver": ["223.5.5.5","119.29.29.29"],
  // 直连走这里
  "direct-nameserver": direct,
  // 会优先走这个配置项
  "nameserver-policy": {
    "geosite:category-ads-all": ["rcode://name_error"],
    "geosite:geolocation-cn,category-games@cn":
      ["system",...direct],
  },
  // 其次nameserver 与 fallback 一起查询，使用fallback-filter确认该采用哪个
  nameserver: direct,
  // 国外doh 必须使用域名请求
  fallback: [
    "https://cloudflare-dns.com/dns-query",
    "https://dns.google/dns-query",
  ],
};

const geoxURL = {
  geosite:
    "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat",
  geoip:
    "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat",
  mmdb: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.metadb",
  asn: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/GeoLite2-ASN.mmdb",
};

const countryMeta = {
  香港: {
    pattern: "(?i)香港|港|HK|hk|Hong Kong|HongKong|hongkong|🇭",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Hong_Kong.png",
  },
  澳门: {
    pattern: "(?i)澳门|MO|Macau|🇲",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Macao.png",
  },
  台湾: {
    pattern: "(?i)台|新北|彰化|TW|Taiwan|🇹",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Taiwan.png",
  },
  新加坡: {
    pattern: "(?i)新加坡|坡|狮城|SG|Singapore|🇸",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Singapore.png",
  },
  日本: {
    pattern: "(?i)日本|川日|东京|大阪|泉日|埼玉|沪日|深日|JP|Japan|🇯",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Japan.png",
  },
  韩国: {
    pattern: "(?i)KR|Korea|KOR|首尔|韩|韓|🇰",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Korea.png",
  },
  美国: {
    pattern: "(?i)美国|美|US|United States|🇺",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/United_States.png",
  },
  马来西亚: {
    pattern: "(?i)马来西亚|马来|MY|Malaysia|🇲",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Malaysia.png",
  },
  澳大利亚: {
    pattern: "(?i)澳洲|澳大利亚|AU|Australia|🇦",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Australia.png",
  },
};

function parseCountry(config) {
  const proxies = config.proxies || [];
  // 统计各个国家节点数
  const countryCounts = Object.create(null);
  // 构建地区正则表达式，去除(?i)
  const compileRegex = {};
  for (const [country, meta] of Object.entries(countryMeta)) {
    compileRegex[country] = new RegExp(
      meta.pattern.replace(/^\(\?i\)/, ""),
      "i",
    );
  }

  for (const proxy of proxies) {
    const name = proxy.name || "";
    // 找到第一个匹配的地区计数就终止
    for (const [country, re] of Object.entries(compileRegex)) {
      if (re.test(name)) {
        countryCounts[country] = (countryCounts[country] || 0) + 1;
        break;
      }
    }
  }

  // 将结果转换为数组对象
  const result = [];
  for (const [country, count] of Object.entries(countryCounts)) {
    result.push({ country, count });
  }
  return result;
}

function buildCountryProxyGroups(countryInfo) {
  const countryProxyGroups = [];

  // 为实际存在的地区创建节点组
  for (const info of countryInfo) {
    const country = info.country;
    const groupName = `${country}节点`;
    const pattern = countryMeta[country].pattern;
    const groupConfig = {
      name: groupName,
      icon: countryMeta[country].icon,
      "include-all": true,
      filter: pattern,
      type: loadBalance ? "load-balance" : "url-test",
    };

    if (!loadBalance) {
      Object.assign(groupConfig, {
        url: "https://cp.cloudflare.com/generate_204",
        interval: 60,
        tolerance: 20,
        lazy: false,
      });
    }
    countryProxyGroups.push(groupConfig);
  }
  return countryProxyGroups;
}

function buildProxyGroups(countryProxyGroups) {
  return [
    {
      name: "default",
      icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Direct.png",
      type: "select",
      proxies: ["DIRECT", "PROXY", "ALL"],
    },
    {
      name: "PROXY",
      icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Proxy.png",
      type: "select",
      proxies: ["DIRECT", "香港节点", "台湾节点", "新加坡节点", "ALL"],
    },
    {
      name: "AI",
      icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Bot.png",
      type: "select",
      proxies: ["台湾节点", "新加坡节点", "ALL"],
    },
    {
      name: "TG",
      icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Global.png",
      type: "select",
      proxies: ["PROXY","香港节点","台湾节点","新加坡节点","ALL"]
    },
    {
      name: "ALL",
      icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Global.png",
      type: "select",
      "include-all": true,
    },
    ...countryProxyGroups,
  ].filter(Boolean);
}

function parseBool(value) {
  if (typeof value === "boolean") return value;
  if (typeof value === "string") {
    return value.toLowerCase() === "true" || value === "1";
  }
  return false;
}

function main(config) {
  config = { proxies: config.proxies };
  const countryInfo = parseCountry(config);
  const countryProxyGroups = buildCountryProxyGroups(countryInfo);
  const proxyGroups = buildProxyGroups(countryProxyGroups);

  if (full) {
    Object.assign(config, {
      "mixed-port": 7890,
      "redir-port": 7892,
      "tproxy-port": 7893,
      "routing-mark": 6666,
      "allow-lan": true,
      mode: "rule",
      "unified-delay": true,
      "tcp-concurrent": true,
      tun: tunConfig,
      profile: {
        "store-selected": true,
        "store-fake-ip": true
      },
    });
  }

  Object.assign(config, {
    "proxy-groups": proxyGroups,
    "rule-providers": ruleProviders,
    rules: rules,
    sniffer: sniffConfig,
    dns: dnsConfig,
    "geodata-mode": true,
    "geo-auto-update": true,
    "geo-update-interval": 24,
    "geox-url": geoxURL,
  });

  return config;
}
