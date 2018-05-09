# httpdump
A complete openresty-based tool for dumping restful request &amp; response in json format log.

- 支持输出过滤规则，可选择输出request body 或 response body 或 request&response body

- 支持输出多日志文件

- 支持多日志文件应用不同的过滤规则

- 日志每分钟自动切割，可配合logstash、flume 日志收集

- 日志输出为标准的json字符串
