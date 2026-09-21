"""dlt pipeline to ingest book data from the Open Library API."""

import dlt
from dlt.sources.rest_api import rest_api_resources
from dlt.sources.rest_api.typing import RESTAPIConfig


@dlt.source
def open_library_source(query: str = "subject:fiction"):
    """Ingest books/editions from the Open Library search API.

    Args:
        query: Search query string. Defaults to 'subject:fiction' for a broad sample.
            Note: Open Library does not support wildcard queries (e.g. '*').
    """
    config: RESTAPIConfig = {
        "client": {
            "base_url": "https://openlibrary.org/",
            # No authentication required — Open Library is a public API.
            # Identify ourselves via User-Agent to get a higher rate limit (3 req/s).
            "headers": {
                "User-Agent": "dlt-open-library-pipeline/1.0 (data engineering demo)"
            },
        },
        "resource_defaults": {
            "primary_key": "key",
            "write_disposition": "replace",
        },
        "resources": [
            {
                "name": "editions",
                "endpoint": {
                    "path": "search.json",
                    "params": {
                        "q": query,
                        "limit": 100,
                        # Request only the fields we care about to keep payloads small.
                        "fields": (
                            "key,title,author_name,author_key,"
                            "first_publish_year,edition_count,"
                            "isbn,language,subject,publisher,"
                            "cover_i,ebook_access"
                        ),
                    },
                    # The search response wraps results in a "docs" array.
                    "data_selector": "docs",
                    "paginator": {
                        "type": "offset",
                        "limit": 100,
                        "limit_param": "limit",
                        "offset_param": "offset",
                        "total_path": "numFound",
                        "maximum_offset": 500,  # cap at 500 records for initial exploration
                    },
                },
            },
        ],
    }

    yield from rest_api_resources(config)


pipeline = dlt.pipeline(
    pipeline_name="open_library_pipeline",
    destination="duckdb",
    dataset_name="open_library",
    # Drop and reload on each run while iterating; remove once stable.
    refresh="drop_sources",
    progress="log",
)


if __name__ == "__main__":
    load_info = pipeline.run(open_library_source())
    print(load_info)  # noqa: T201
