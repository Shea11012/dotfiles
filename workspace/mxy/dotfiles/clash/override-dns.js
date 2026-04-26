// https://clashparty.org/docs/guide/override/javascript
const nameServerPolicy = {
    "+.ascwqw.org": [
        "https://119.29.29.29/dns-query",
        "https://223.5.5.5/dns-query",
    ],
};

const providerRules = [
    "IP-CIDR,8.163.0.248/32,DIRECT,no-resolve",
    "IP-CIDR,8.138.100.160/32,DIRECT,no-resolve",
    "IP-CIDR,216.38.168.42/32,DIRECT,no-resolve",
    "DOMAIN-SUFFIX,ascwqw.org,DIRECT",
];

const hosts = { "+.local": "192.168.0.105" };

function main(config) {
    config.hosts = { ...config.hosts, ...hosts };

    config.dns["nameserver-policy"] = {
        ...nameServerPolicy,
        ...config.dns["nameserver-policy"],
    };
    config.dns["fake-ip-filter"] = [
        "+.ascwqw.org",
        ...config.dns["fake-ip-filter"],
    ];

    config.rules = [...providerRules, ...config.rules];

    return config;
}
