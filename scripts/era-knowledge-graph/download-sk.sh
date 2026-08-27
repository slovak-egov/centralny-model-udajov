#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "${script_dir}/../.." && pwd)"
snapshot_date="${ERA_SNAPSHOT_DATE:-$(date -u +%F)}"
output_dir="${1:-${repo_root}/raw/era-knowledge-graph/${snapshot_date}}"

repository_url="https://graph.data.era.europa.eu/repositories/rinf-plus"
statements_url="${repository_url}/statements"
graph_iri="http://data.europa.eu/949/graph/0056"
zenodo_latest_url="https://zenodo.org/api/records/14605743/versions/latest"

for command_name in curl gzip jq riot sha256sum; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Missing required command: ${command_name}" >&2
    exit 1
  fi
done

mkdir -p -- "${output_dir}"
temporary_dir="$(mktemp -d)"
trap 'rm -rf -- "${temporary_dir}"' EXIT

retrieved_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
raw_file="${temporary_dir}/era-rinf-sk-graph-0056.nq"

curl --fail --silent --show-error --get \
  --header 'Accept: application/n-quads' \
  --data-urlencode "context=<${graph_iri}>" \
  --output "${raw_file}" \
  "${statements_url}"

riot --validate --syntax=NQUADS "${raw_file}" >/dev/null

statistics_query='SELECT (COUNT(*) AS ?triples) (COUNT(DISTINCT ?s) AS ?subjects) (COUNT(DISTINCT ?p) AS ?predicates) WHERE { GRAPH <http://data.europa.eu/949/graph/0056> { ?s ?p ?o } }'
curl --fail --silent --show-error --get \
  --header 'Accept: text/csv' \
  --data-urlencode "query=${statistics_query}" \
  --output "${output_dir}/graph-statistics.csv" \
  "${repository_url}"

for query_name in \
  sk-class-counts \
  sk-identity-coverage \
  dcat-inventory \
  external-dependencies; do
  curl --fail --silent --show-error --get \
    --header 'Accept: text/csv' \
    --data-urlencode "query@${script_dir}/sparql/${query_name}.rq" \
    --output "${output_dir}/${query_name}.csv" \
    "${repository_url}"
done

curl --fail --silent --show-error --location \
  --output "${output_dir}/zenodo-latest.json" \
  "${zenodo_latest_url}"

downloaded_triples="$(wc -l < "${raw_file}" | tr -d ' ')"
reported_triples="$(awk -F, 'NR == 2 { gsub(/\r|\"/, "", $1); print $1 }' "${output_dir}/graph-statistics.csv")"
if [[ "${downloaded_triples}" != "${reported_triples}" ]]; then
  echo "Downloaded ${downloaded_triples} statements, endpoint reported ${reported_triples}." >&2
  exit 1
fi

raw_bytes="$(wc -c < "${raw_file}" | tr -d ' ')"
raw_sha256="$(sha256sum "${raw_file}" | awk '{print $1}')"
gzip -n -9 --stdout "${raw_file}" > "${output_dir}/era-rinf-sk-graph-0056.nq.gz"
compressed_bytes="$(wc -c < "${output_dir}/era-rinf-sk-graph-0056.nq.gz" | tr -d ' ')"
compressed_sha256="$(sha256sum "${output_dir}/era-rinf-sk-graph-0056.nq.gz" | awk '{print $1}')"

jq -n \
  --arg classification "derived-snapshot" \
  --arg retrievedAt "${retrieved_at}" \
  --arg repository "${repository_url}" \
  --arg graph "${graph_iri}" \
  --arg statements "${statements_url}" \
  --arg mediaType "application/n-quads" \
  --arg sha256 "${raw_sha256}" \
  --arg compressedSha256 "${compressed_sha256}" \
  --argjson triples "${downloaded_triples}" \
  --argjson bytes "${raw_bytes}" \
  --argjson compressedBytes "${compressed_bytes}" \
  --slurpfile zenodo "${output_dir}/zenodo-latest.json" \
  '{
    schemaVersion: 1,
    classification: $classification,
    description: "Unmodified snapshot of the ERA RINF named graph 0056. ERA entity IRIs are preserved.",
    retrievedAt: $retrievedAt,
    source: {
      publisher: "European Union Agency for Railways",
      repository: $repository,
      namedGraph: $graph,
      statementsEndpoint: $statements,
      requestAccept: $mediaType
    },
    artifact: {
      path: "era-rinf-sk-graph-0056.nq.gz",
      mediaType: "application/n-quads",
      compression: "gzip",
      triples: $triples,
      uncompressedBytes: $bytes,
      compressedBytes: $compressedBytes,
      uncompressedSha256: $sha256,
      sha256: $compressedSha256
    },
    latestFullDumpAtRetrieval: {
      record: $zenodo[0].links.self_html,
      doi: $zenodo[0].doi,
      version: $zenodo[0].metadata.version,
      publicationDate: $zenodo[0].metadata.publication_date,
      license: $zenodo[0].metadata.license.id,
      files: [$zenodo[0].files[] | {name: .key, bytes: .size, checksum: .checksum, download: .links.self}]
    },
    identityPolicy: {
      contentEntityIrisRewritten: false,
      localMetadataBase: "https://slovpedia.eu/"
    }
  }' > "${output_dir}/source-manifest.json"

(
  cd -- "${output_dir}"
  sha256sum \
    era-rinf-sk-graph-0056.nq.gz \
    graph-statistics.csv \
    sk-class-counts.csv \
    sk-identity-coverage.csv \
    dcat-inventory.csv \
    external-dependencies.csv \
    zenodo-latest.json \
    source-manifest.json > checksums.sha256
)

echo "ERA Slovakia snapshot created in ${output_dir}"
echo "Triples: ${downloaded_triples}; compressed bytes: ${compressed_bytes}; SHA-256: ${compressed_sha256}"
