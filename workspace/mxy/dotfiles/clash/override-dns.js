// https://clashparty.org/docs/guide/override/javascript
const customPoxyRules = [
    "DOMAIN-SUFFIX,alicesw.org,PROXY",
    "DOMAIN-SUFFIX,8xsk.com,PROXY",
    "DOMAIN-SUFFIX,66img.cc,PROXY",
    "DOMAIN-SUFFIX,thumbsnap.com,PROXY",
    "DOMAIN-SUFFIX,image.233233.fun,PROXY",
    "DOMAIN-SUFFIX,novelia.cc,PROXY",
    "DOMAIN-KEYWORD,sxsy,PROXY",
    "DOMAIN-SUFFIX,novel543.com,PROXY",
    "DOMAIN-SUFFIX,gyks.cf,PROXY",
];

const nameServerPolicy = {
    "+.ascwqw.org,pplinks.ascwqw.org": [
        "https://119.29.29.29/dns-query",
        "https://223.5.5.5/dns-query",
    ],
};

const providerRules = [
    "IP-CIDR,216.38.168.42/32,DIRECT,no-resolve",
    "DOMAIN-SUFFIX,ascwqw.org,DIRECT",
    "DOMAIN-SUFFIX,pplinks.ascwqw.org,DIRECT",
];

function main(config) {
    config.dns["nameserver-policy"] = {
        ...nameServerPolicy,
        ...config.dns["nameserver-policy"],
    };
    config.dns["fake-ip-filter"] = [
        "+.ascwqw.org",
        ...config.dns["fake-ip-filter"],
    ];

    config.rules = [...providerRules, ...customPoxyRules, ...config.rules];

    return config;
}
