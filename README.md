# HMRC Manuals API

Provides an API for a system built by HMRC to publish tax manuals onto GOV.UK. In many
ways it is analogous to a backend/admin app for publishing on GOV.UK. Content which
passes validation and checks for unsanitary content is submitted to the GOV.UK
Publishing API application. The application does not have a database itself. An HMRC
manual consists of two document types: the manual itself and manual sections.

## Nomenclature

- **Manual**: HMRC manual with title and description, contains many Sections. See [Adding or updating a manual](docs/extended_documentation.md#adding-or-updating-a-manual) for more details. Before adding a manual through the api, a [new slug should be added](#adding-a-new-slug) to the list of known slugs.

- **Section**: Sections can contain sub-sections and/or a content body. See [Adding or updating a section](docs/extended_documentation.md#adding-or-updating-a-manual-section) for more details.

<a name="adding-a-new-slug"></a>
## Adding a new slug

Before adding a new manual through the api, the slug for the manual must be added to [/config/initializers/known_manual_slugs.rb](config/initializers/known_manual_slugs.rb) and the application re-deployed.

The workflow for this is likely to be initiated by a Zendesk ticket raised by HMRC with the new slug. A developer can
then add the slug and re-deploy the application and inform HMRC that the slug is ready to be published against.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

```sh
bundle exec rspec
```

## Manuals and decisions

See the [extended documentation](docs/extended_documentation.md) for details:

- [Connecting to the API](docs/extended_documentation.md#connecting-to-the-api)
- [Adding or updating a manual](docs/extended_documentation.md#adding-or-updating-a-manual)
- [Adding or updating a section](docs/extended_documentation.md#adding-or-updating-a-manual-section)
- [Responses to PUT requests](docs/extended_documentation.md#possible-responses-to-put-requests)
- [Slugs, Section Ids and Urls](docs/extended_documentation.md#slugs-section-ids-and-urls)
- [Content Ids](docs/extended_documentation.md#content-ids)
- [Markup](docs/extended_documentation.md#markup)
- [Manual Tags](docs/extended_documentation.md#manual-tags)
- [Removing published manuals](docs/extended_documentation.md#removing-published-manuals)
- [Testing publishing in GOV.UK Docker](docs/extended_documentation.md#testing-publishing-in-govuk-docker)
- [Managing manuals and sections with rake](docs/extended_documentation.md#managing-manuals-and-sections-with-rake)
- [Responses to PUT requests](docs/extended_documentation.md#possible-responses-to-put-requests)

## Licence

[MIT License](LICENCE)
