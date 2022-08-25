#standardSQL
SELECT
jsonPayload.src_vpc.vpc_name,
SUM(CAST(jsonPayload.bytes_sent AS INT64)) AS bytes,
jsonPayload.src_vpc.subnetwork_name,
jsonPayload.connection.src_ip,
jsonPayload.connection.src_port,
jsonPayload.connection.dest_ip,
jsonPayload.connection.dest_port,
jsonPayload.connection.protocol
FROM
`flow_logs.*`
GROUP BY
jsonPayload.src_vpc.vpc_name,
jsonPayload.src_vpc.subnetwork_name,
jsonPayload.connection.src_ip,
jsonPayload.connection.src_port,
jsonPayload.connection.dest_ip,
jsonPayload.connection.dest_port,
jsonPayload.connection.protocol
ORDER BY
bytes DESC
LIMIT
15
