# HMRC Manuals API

This app provides URLs for pushing HMRC manuals to the GOV.UK Publishing API.

## Connecting to the API

The base path for the preview environment is:
https://hmrc-manuals-api.preview.alphagov.co.uk

Authentication is done with a token, which needs to be supplied in the Authorization HTTP header, like this:

```Authorization: Bearer your_token```

You also need to supply an accept header and a content-type header:

    Accept: application/json
    Content-Type: application/json

Please note that:
* Tokens are environment specific, so preview and production will have different tokens.
* The data on preview is overwritten every night with data from production

## Adding or updating a manual

### Request

`PUT /hmrc-manuals/<slug>`.

### Example JSON

[See an example manual](json_examples/requests/employment-income-manual.json)


### JSON Schema

[JSON Schema for manuals](public/manual-schema.json)

## Adding or updating a manual section

### Request

`PUT /hmrc-manuals/<manual-slug>/sections/<section_id>`.

### Example JSON

1. [An example first-level section, with children](json_examples/requests/employment-income-manual/EIM11800.json)
1. [An example third-level section](json_examples/requests/employment-income-manual/EIM25525.json)
1. [An example section with ungrouped children](json_examples/requests/employment-income-manual/EIM11200.json) (the group title is omitted and only one group included)


### JSON Schema

[JSON Schema for sections](public/section-schema.json)

## Possible responses to PUT requests

* `200`: updated successfully
* `201`: created successfully
* `400`: the request JSON isn't well-formed.
* `409`: the slug is taken by content that is managed by another publishing tool.
* `422`: there's a validation error. A response body would detail the errors:

    ```json
    {
      "status": "error",
      "errors": [
        "error_message_1",
        "error_message_2",
        ...
      ]
    }
    ```

* `503`: the request could not be completed because the API or the Publishing API is unavailable.

## Content post-processing

All `description` and `body` attributes in manuals or manual sections may contain
[markdown](http://daringfireball.net/projects/markdown/syntax). The markdown in those attributes
is converted to HTML before the document is sent to the Publishing API.

There is a whitelist of allowed HTML tags and attributes. If a manual or a section
contains any disallowed HTML in any field, the request is rejected with a validation error (status code `422`).

The following tags are allowed:
```
a, abbr, b, bdo, blockquote, br, caption, cite, code, col, colgroup, dd, del, dfn, div, dl, dt, em, figcaption, figure, h1, h2, h3, h4, h5, h6, hgroup, hr, i, img, ins, kbd, li, mark, ol, p, pre, q, rp, rt, ruby, s, samp, small, strike, strong, sub, sup, table, tbody, td, tfoot, th, thead, time, tr, u, ul, var, wbr.
```

The following tag attributes are allowed:
```
{:all=>["dir", "lang", "title", "id", "class"], "a"=>["href", "rel"], "blockquote"=>["cite"], "col"=>["span", "width"], "colgroup"=>["span", "width"], "del"=>["cite", "datetime"], "img"=>["align", "alt", "height", "src", "width"], "ins"=>["cite", "datetime"], "ol"=>["start", "reversed", "type"], "q"=>["cite"], "table"=>["summary", "width"], "td"=>["abbr", "axis", "colspan", "rowspan", "width"], "th"=>["abbr", "axis", "colspan", "rowspan", "scope", "width"], "time"=>["datetime", "pubdate"], "ul"=>["type"]}
```
