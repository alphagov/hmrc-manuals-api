# [DRAFT]
Last updated: 02/09/2026

# Managing assets

The assets endpoints allow clients to upload, update, replace, publish and retrieve assets associated with HMRC manuals.

## Common headers

These headers apply to all endpoints.

### Request headers

Request headers marked as required must be included with all requests.

| Header          | Required | Description                                                  |
| --------------- | -------- | ------------------------------------------------------------ |
| `Authorization` | Yes      | Bearer token used to authenticate the request.               |
| `Accept`        | No       | Defaults to `application/json`.                              |

### Response headers

| Header         | Description                                                 |
| -------------- | ----------------------------------------------------------- |
| `Content-Type` | `application/json`                                          |

## Response fields

All endpoints return a JSON body describing the asset, always including these fields:

| Field            | Description                                                                                                            |
| ---------------- | --------------------------------------------------------------------------------------------------------------------- |
| `_response_info` | Status of the request: `"created"` for uploads, `"ok"` for reads, and `"success"` for updates, deletes, restores and access regeneration. |
| `id`             | Canonical URL identifying the asset. Its final path segment is the `asset_id`.                                       |
| `asset_id`       | Identifier for the asset, used in this API's asset paths (e.g. `/assets/{asset_id}`).                                |
| `name`           | File name.                                                                                                           |
| `content_type`   | MIME type of the file.                                                                                               |
| `size`           | File size in bytes.                                                                                                  |
| `file_url`       | URL the asset file is served from. For draft assets this includes a time-limited access token.                       |
| `state`          | Processing state of the asset: `"unscanned"`, `"clean"`, `"infected"` or `"uploaded"`.                               |
| `draft`          | Whether the asset is a draft: `true` or `false`.                                                                     |
| `deleted`        | Whether the asset is marked as deleted: `true` or `false`.                                                           |

### Conditional fields

These fields appear only in certain responses:

| Field            | Condition         | Description                                                          |
| ---------------- | ----------------- | ------------------------------------------------------------------- |
| `preview_expiry` | Draft assets      | Timestamp representing when the access token in `file_url` expires. |
| `replacement_id` | Superseded assets | ID of the asset that supersedes this one.                           |

## Upload a new asset

```http
POST /assets
Content-Type: multipart/form-data
```

Uploads the asset, optionally making it publicly available. The asset will be scanned for viruses and other potentially malicious content before upload.

### Request parameters

| Parameter               | Required | Description                                                                                          |
| ----------------------- | -------- | ---------------------------------------------------------------------------------------------------- |
| `asset[file]`           | Yes      | File to upload.                                                                                      |
| `asset[draft]`          | No       | Whether the asset is uploaded as a draft. Defaults to `true`. Set to `false` to make the asset publicly available immediately after upload.|

### Response codes

| Status                     | Description                            |
| -------------------------- | -------------------------------------- |
| `201 Created`              | Asset successfully uploaded.           |
| `400 Bad Request`          | A required parameter was not provided. |
| `401 Unauthorized`         | Authentication failed.                 |
| `413 Payload Too Large`    | Uploaded file exceeds permitted size.  |
| `422 Unprocessable Entity` | Asset could not be created.            |

### Example

#### Request

```bash
curl -X POST \
  https://hmrc-manuals-api.publishing.service.gov.uk/assets \
  -H "Authorization: Bearer <token>" \
  -F "asset[file]=@logo.png"
```

#### Response

```json
{
  "_response_info": { "status": "created" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "asset_id": "6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://draft-assets.publishing.service.gov.uk/media/6a216e0509c4d5e2e98bd731/logo.png?token=eyJhbGciOiAIUzI1PiJ9.eyJzdWIiOiJkYmU3NmNiZC1kNmUjLTQzODItODA4OC01NDdkZGZiMzcwMWUiLCJjb250ZW50X2lkIjoiMmU0MDU3NTQtNTI1ZS00MjQ2LWJmZjgtYmI4ZjkwNzBiNTM4IiwiaWF0IjoxNzgxMDgxMjEwLCJleHAiOjE3ODM2NzMyMHB9.Uvqe1aHgGp_wxCTIyXMNB8COwBo9frs2l2SskZTBJ_Q",
  "state": "unscanned",
  "draft": true,
  "deleted": false,
  "preview_expiry": "2026-07-10T08:31:14Z" //  30 days after creation or when the asset is published
}
```

#### Accessing draft assets

Draft assets are not publicly accessible and are hosted on the https://draft-assets.publishing.service.gov.uk/ domain.

The `file_url` returned in the asset response includes a time-limited access token and can be used directly to retrieve the asset:

```http
GET https://draft-assets.publishing.service.gov.uk/media/6a216e0509c4d5e2e98bd731/logo.png?token=<jwt-token>
```

If the access token is valid, the draft asset will be served. Otherwise, access will be denied.
Access tokens expire 30 days after they are issued or when asset is published, whichever occurs first. A new token can be regenerated using the `POST /assets/:id/regenerate-access` endpoint.


## Get asset information

```http
GET /assets/{asset-id}
```

Returns metadata for an asset.

### Path parameters

| Parameter  | Description                     |
| ---------- | ------------------------------- |
| `asset-id` | Unique identifier of the asset. |

### Response codes

| Status          | Description                                        |
| --------------- | -------------------------------------------------- |
| `200 OK`        | Asset metadata returned.                           |
| `403 Forbidden` | You don't have permission to access this resource. |
| `404 Not Found` | Asset does not exist.                              |

### Example

#### Request

```bash
curl https://hmrc-manuals-api.publishing.service.gov.uk/assets/6a216e0509c4d5e2e98bd731 \
  -H "Authorization: Bearer <token>"
```

#### Response

```json
{
  "_response_info": { "status": "ok" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "asset_id": "6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/6a216e0509c4d5e2e98bd731/logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": false
}
```

Replaced (superseded) assets will include `replacement_id`:

```json
{
  "_response_info": { "status": "ok" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "asset_id": "6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/6a216e0509c4d5e2e98bd731/logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": false,
  "replacement_id": "7a216e0509c4d5e2e98bd842"
}
```

## Regenerate draft asset access

```http
POST /assets/{asset-id}/regenerate-access
```

Resets and generates a new preview link for a draft asset and returns an updated preview URL.

Draft asset access tokens expire 30 days after they are issued. Use this endpoint to generate a new token when the existing token has expired or is about to expire.

The response includes a refreshed `file_url` containing the new token and an updated `preview_expiry` timestamp.
This operation will disable the previous preview link.

### Path parameters

| Parameter  | Description                     |
| ---------- | ------------------------------- |
| `asset-id` | Unique identifier of the asset. |

### Response codes

| Status                     | Description                     |
| -------------------------- | ------------------------------- |
| `201 Created`              | New preview link generated.     |
| `401 Unauthorized`         | Authentication failed.          |
| `404 Not Found`            | Asset does not exist.           |
| `422 Unprocessable Entity` | Access couldn't be regenerated. |

### Example

#### Request

```bash
curl -X POST \
  https://hmrc-manuals-api.publishing.service.gov.uk/assets/6a216e0509c4d5e2e98bd731/regenerate-access \
  -H "Authorization: Bearer <token>"
```

#### Response

```json
{
  "_response_info": { "status": "success" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "asset_id": "6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://draft-assets.publishing.service.gov.uk/media/6a216e0509c4d5e2e98bd731/logo.png?token=eyJhbGciOiAIUzI1PiJ9.eyJzdWIiOiJkYmU3NmNiZC1kNmUjLTQzODItODA4OC01NDdkZGZiMzcwMWUiLCJjb250ZW50X2lkIjoiMmU0MDU3NTQtNTI1ZS00MjQ2LWJmZjgtYmI4ZjkwNzBiNTM4IiwiaWF0IjoxNzgxMDgxMjEwLCJleHAiOjE3ODM2NzMyMHB9.Uvqe1aHgGp_wxCTIyXMNB8COwBo9frs2l2SskZTBJ_Q",
  "state": "uploaded",
  "draft": true,
  "deleted": false,
  "preview_expiry": "2026-08-10T08:31:14Z"
}
```

## Delete asset

```http
DELETE /assets/{asset-id}
```

Marks an asset as deleted.

### Path parameters

| Parameter  | Description                     |
| ---------- | ------------------------------- |
| `asset-id` | Unique identifier of the asset. |

### Response codes

| Status          | Description                   |
| --------------- | ----------------------------- |
| `200 OK`        | Asset marked as deleted.      |
| `403 Forbidden` | Access to asset is forbidden. |
| `404 Not Found` | Asset does not exist.         |

### Example

#### Request

```bash
curl -X DELETE \
  https://hmrc-manuals-api.publishing.service.gov.uk/assets/6a216e0509c4d5e2e98bd731 \
  -H "Authorization: Bearer <token>"
```

#### Response

```json
{
  "_response_info": { "status": "success" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "asset_id": "6a216e0509c4d5e2e98bd731",
  "name": "updated-logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/6a216e0509c4d5e2e98bd731/updated-logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": true
}
```

## Restore deleted asset

```http
POST /assets/{asset-id}/restore
```

Restores a previously deleted asset.

### Path parameters

| Parameter  | Description                     |
| ---------- | ------------------------------- |
| `asset-id` | Unique identifier of the asset. |

### Response codes

| Status          | Description                   |
| --------------- | ----------------------------- |
| `200 OK`        | Asset restored.               |
| `403 Forbidden` | Access to asset is forbidden. |
| `404 Not Found` | Asset does not exist.         |

### Example

#### Request

```bash
curl -X POST \
  https://hmrc-manuals-api.publishing.service.gov.uk/assets/6a216e0509c4d5e2e98bd731/restore \
  -H "Authorization: Bearer <token>"
```

#### Response

```json
{
  "_response_info": { "status": "success" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "asset_id": "6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/6a216e0509c4d5e2e98bd731/logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": false
}
```

## Update asset

```http
PUT /assets/{asset-id}
Content-Type: multipart/form-data
```

Updates an existing asset. This endpoint supports multiple update operations including:

- publishing a draft asset
- replacing the file
- linking a replacement asset

All fields are optional, but at least one must be provided.

This is a partial update operation so only the attributes included in the request will be changed.

### Path parameters

| Parameter  | Description                     |
| ---------- | ------------------------------- |
| `asset-id` | Unique identifier of the asset. |

### Request parameters

| Parameter               | Required | Description                                                                               |
| ----------------------- | -------- | ----------------------------------------------------------------------------------------- |
| `asset[draft]`          | No       | Publishes or unpublishes the asset. Set to `false` to make the asset publicly available.  |
| `asset[file]`           | No       | Replaces the file associated with the asset.                                              |
| `asset[replacement_id]` | No       | ID of another asset that replaces this one. Used to mark the current asset as superseded. |

You must provide at least one parameter.

### Response codes

| Status                     | Description                           |
| -------------------------- | ------------------------------------- |
| `200 OK`                   | Asset updated.                        |
| `403 Forbidden`            | Access to asset is forbidden.         |
| `404 Not Found`            | Asset does not exist.                 |
| `413 Payload Too Large`    | Uploaded file exceeds permitted size. |
| `422 Unprocessable Entity` | Asset update failed.                  |

### Example

#### Request

```bash
curl -X PUT \
  https://hmrc-manuals-api.publishing.service.gov.uk/assets/6a216e0509c4d5e2e98bd731 \
  -H "Authorization: Bearer <token>" \
  -F "asset[draft]=false"
```

#### Response

```json
{
  "_response_info": { "status": "success" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "asset_id": "6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/6a216e0509c4d5e2e98bd731/logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": false
}
```

Replaced (superseded) assets will include `replacement_id`.


### Use cases

- Publishing
  If `asset[draft]` is set to `false`, a draft asset becomes publicly available. This also invalidates any existing draft access tokens. The domain in asset URL will change from `draft-assets.publishing.service.gov.uk` to `assets.publishing.service.gov.uk`.

- File replacement
  If `asset[file]` is provided, the existing file is replaced and the asset retains its `asset_id`. The `file_url` will change if the file name is different to the original.

- Replacement linking
  If `asset[replacement_id]` is provided, the asset is marked as replaced by another asset. The original asset remains accessible but is considered superseded.

## Replacing asset workflow guide

There are two ways to replace an asset:

1. **In-place replacement** – update the file on the existing asset.
2. **Replacement via new asset** – upload a new asset and link it to the original using a `replacement_id`.


### Option 1: In-place replacement

This replaces the file on an existing asset while keeping the same `asset_id`.

Use this when you want to update an asset without creating a new record.

#### Request

```http
PUT /assets/{asset-id}
Content-Type: multipart/form-data
```

| Parameter     | Required | Description       |
| ------------- | -------- | ----------------- |
| `asset[file]` | Yes      | Replacement file. |

#### Result

* The existing asset is updated in place
* The `asset_id` remains unchanged
* The file URL is updated, if the file name changed.

### Option 2: Replace via new asset

This creates a new asset and links it to the original using `replacement_id`.

#### Step 1: Upload new asset

```http
POST /assets
Content-Type: multipart/form-data
```

#### Step 2: Link replacement to original asset

```http
PUT /assets/{old-asset-id}
Content-Type: multipart/form-data
```

| Parameter               | Required | Description                                     |
| ----------------------- | -------- | ----------------------------------------------- |
| `asset[replacement_id]` | Yes      | ID of the new asset that replaces the original. |

#### Result

* Original asset remains unchanged
* A `replacement_id` is stored on the original asset
* Clients can detect that the asset has been superseded
