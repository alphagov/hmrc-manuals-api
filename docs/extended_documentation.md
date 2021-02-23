# HMRC Manuals API - Extended Documentation

This app provides URLs for pushing HMRC manuals to the GOV.UK Publishing API.

## Connecting to the API

The base path for the integration environment is:
https://hmrc-manuals-api.integration.publishing.service.gov.uk

...and the one for production is:
https://hmrc-manuals-api.publishing.service.gov.uk

Authentication is done with a token, which needs to be supplied in the `Authorization` HTTP header, like this:

    Authorization: Bearer your_token

You also need to supply an accept header and a Content-Type header:

    Accept: application/json
    Content-Type: application/json

Please note that:

* Tokens are environment specific, so integration and production will have different tokens.
* The data on integration is overwritten every night with data from production.

## Adding or updating a manual

### Request

    PUT /hmrc-manuals/<slug>

The `<slug>` is used as part of the GOV.UK URL for the document.

### Example JSON

[See an example manual](/public/json_examples/requests/employment-income-manual.json)


### JSON Schema

[JSON Schema for manuals](/public/manual-schema.json)

## Adding or updating a manual section

### Request

    PUT /hmrc-manuals/<manual-slug>/sections/<section_slug>

The `<manual-slug>` and `<section_slug>` will be used as part of the GOV.UK URL for the document. The `<section_slug>` will be the section ID converted to lowercase.

### Example JSON

1. [An example first-level section, with children](/public/json_examples/requests/employment-income-manual/eim11800.json)
1. [An example third-level section](/public/json_examples/requests/employment-income-manual/eim25525.json)
1. [An example section with ungrouped children](/public/json_examples/requests/employment-income-manual/eim11200.json) (the group title is omitted and only one group included)


### JSON Schema

[JSON Schema for sections](/public/section-schema.json)

## Possible responses to PUT requests

* `200`: updated successfully
* `201`: created successfully
  * Both `200`s and `201`s return a `Location` header and a response body containing the GOV.UK URL of the manual:

          Location: https://www.gov.uk/hmrc-internal-manuals/<manual_slug>/<section_slug>

          {
            "govuk_url": "https://www.gov.uk/hmrc-internal-manuals/<manual_slug>/<section_slug>"
          }

* `400`: the request JSON isn't well-formed.
* `409`: the slug is taken by content that is managed by another publishing tool.
* `422`: there's a validation error. A response body would detail the errors:

        {
          "status": "error",
          "errors": [
            "error_message_1",
            "error_message_2",
            ...
          ]
        }

* `503`: the request could not be completed because the API or the Publishing API is unavailable.

## Slugs, section IDs and URLs

GOV.UK has [URL standards](https://insidegovuk.blog.gov.uk/url-standards-for-gov-uk/)
to ensure that the URLs are SEO and user friendly.

This API constructs the GOV.UK URLs based upon the slugs and section IDs supplied to it.

Slugs are validated to ensure that they fit the GOV.UK styleguide according to these rules:

* only lowercase letters, numbers and dashes are allowed
* no leading or trailing dashes

Additionally, users of the API are required to follow the styleguide for slugs:

* slugs should not contain acronyms wherever possible
* dashes should be used to separate words
* articles (a, an, the) and other superfluous words should not be used
* URLs should use the verb stem where possible: eg `apply` instead of `applying`
* no multiple consecutive dashes

Section IDs are validated to ensure that they can be converted to slugs by simply making them lowercase.

## Content IDs

Both manuals and sections have a field `content_id`, which will be required in
the future.

This is a UUID string as described in [RFC 4122](https://www.ietf.org/rfc/rfc4122.txt) ([Wiki](https://en.wikipedia.org/wiki/Universally_unique_identifier)). It is
[validated using this regex](https://github.com/alphagov/publishing-api/blob/1bd2c3d2aaa4681fe6286548aa16a4b5f66367c9/app/validators/uuid_validator.rb#L10-L24).

For example: "30737dba-17f1-49b4-aff8-6dd4bff7fdca".

This is a unique identifier for the piece of content. It is used as the reference
with which content items can reference other content items on GOV.UK. For example,
it is used for [tagging to topics](https://www.gov.uk/topic).

Manuals and sections should always have a consistent `content_id`. It is not possible
to send a previously-published document with the same slug but a different `content_id`.

Currently, when a manual or section doesn't have a `content_id`, one will be
generated for it. This generated UUID is non-random and based on the `base_path`
of the item.

## Markup

All `body` attributes in manuals or manual sections may contain
[Markdown in the Kramdown dialect](http://kramdown.gettalong.org/syntax.html).
The Markdown in those attributes is converted to HTML before the document is sent to the Publishing API.

There is a whitelist of allowed HTML tags and attributes. If a manual or a section
contains any disallowed HTML in any field, the request is rejected with a validation error (status code `422`).

The following tags are allowed:

```
a, abbr, b, bdo, blockquote, br, caption, cite, code, col, colgroup, dd, del, dfn, div, dl, dt, em, figcaption, figure, h1, h2, h3, h4, h5, h6, hgroup, hr, i, img, ins, kbd, li, mark, ol, p, pre, q, rp, rt, ruby, s, samp, small, strike, strong, sub, sup, table, tbody, td, tfoot, th, thead, time, tr, u, ul, var, wbr.
```

The following tag attributes are allowed, by tag:

* `:all=>["dir", "lang", "title", "id", "class"]`
* `"a"=>["href", "rel"]`
* `"blockquote"=>["cite"]`
* `"col"=>["span", "width"]`
* `"colgroup"=>["span", "width"]`
* `"del"=>["cite", "datetime"]`
* `"img"=>["align", "alt", "height", "src", "width"]`
* `"ins"=>["cite", "datetime"]`
* `"ol"=>["start", "reversed", "type"]`
* `"q"=>["cite"]`
* `"table"=>["summary", "width"]`
* `"td"=>["abbr", "axis", "colspan", "rowspan", "width"]`
* `"th"=>["abbr", "axis", "colspan", "rowspan", "scope", "width"]`
* `"time"=>["datetime", "pubdate"]`
* `"ul"=>["type"]`

### Images

Images are only allowed if on a relative path (ie hosted on `www.gov.uk`) or on
the GOV.UK assets domain: `assets.publishing.service.gov.uk`
(`assets.digital.cabinet-office.gov.uk` is the old GOV.UK assets domain and may
be removed from the whitelist in the future). Markup containing images hosted
on other domains will be rejected with a `422` error code.

On integration, the allowed image domains are expanded to include the integration
www.gov.uk domain (`www-origin.integration.publishing.service.gov.uk`) and the
integration asset domain (`assets-origin.integration.publishing.service.gov.uk`).

## Manual tags

Manuals can be tagged to topics on GOV.UK, so that they're easier for
users to find.

### How tagging works

Use the [content-tagger](https://github.com/alphagov/content-tagger) app to add topic tags to manuals.

## Removing published manuals

The API endpoints of the app do not cover removal of manuals. There is a rake task for this purpose. Removal means replacing the published manual with a 410 Gone document. As manuals can have sections underneath them removal does the same for each section that is a child of the manual.

The rake task is invoked as follows:

```
$ cd /var/apps/hmrc-manuals-api
$ sudo -u deploy govuk_setenv hmrc-manuals-api bundle exec rake remove_hmrc_manuals[slug-to-remove-1,slug-to-remove-2,...,slug-to-remove-n]
```

## Testing publishing in GOV.UK Docker

You can use the JSON examples of requests for testing publishing in development,
for example with cURL from the root directory of the repository:

```
curl -i -XPUT -H'Authorization: Bearer faketoken' -H'Accept: application/json' \
  -H'Content-Type: application/json' --data-binary \
  @public/json_examples/requests/employment-income-manual.json \
  http://hmrc-manuals-api.dev.gov.uk/hmrc-manuals/test-manual
```

Or with [HTTPie](https://github.com/jkbrzt/httpie):

```
http PUT http://hmrc-manuals-api.dev.gov.uk/hmrc-manuals/test-manual \
  Authorization:'Bearer faketoken' Accept:application/json Content-Type:application/json \
  < public/json_examples/requests/employment-income-manual.json
```

In development mode the API doesn't require a valid bearer token; any value is
accepted. To test publishing to our Integration or Staging environments you would
need a real token for the right environment.

## Managing manuals and sections with rake

HMRC Manuals API contains [rake tasks](https://github.com/alphagov/hmrc-manuals-api/tree/master/lib/tasks)
for removing manuals and sections and redirecting sections. These can be run using the [rake Jenkins job](https://docs.publishing.service.gov.uk/manual/running-rake-tasks.html). Where the examples below require a slug as a parameter, this is the last part of the URL without a leading slash, for example given the URL 'https://www.gov.uk/hmrc-internal-manuals/guidance-audit-customs-values' the slug would be 'guidance-audit-customs-values'

### Redirect a section back to the parent manual

To redirect a section back to the parent manual:

```
bundle exec rake redirect_hmrc_section_to_parent_manual[manual-slug,section-slug,section-slug]
```

### Remove a section

Alternatively to remove the section (this makes it a 'gone' route):

```
bundle exec rake remove_hmrc_sections[manual-slug,section-slug,section-slug]
```

### Remove a manual

To completely remove a manual:

```
bundle exec rake remove_hmrc_manuals[manual-slug,manual-slug]
```

This will remove the manuals provided as arguments and all sections within those manuals.
