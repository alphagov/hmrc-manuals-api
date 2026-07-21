# [DRAFT]
Last updated: 21/07/2026

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


## Upload new asset

Uploads a new asset after a clean virus scan result and creates a draft or publicly available asset record.

### Request

```http
POST /assets
Content-Type: multipart/form-data
```

### Request parameters

| Parameter               | Required | Description                                                                                          |
| ----------------------- | -------- | ---------------------------------------------------------------------------------------------------- |
| `asset[file]`           | Yes      | File to upload.                                                                                      |
| `asset[draft]`.         | No       | Whether the asset is uploaded as a draft. Defaults to `true`. Set to `false` to make the asset publicly available immediately after upload.|

### Example request

```bash
curl -X POST \
  https://hmrc-manuals-api.publishing.service.gov.uk/assets \
  -H "Authorization: Bearer <token>" \
  -F "asset[file]=@logo.png"
```

### Success response

```http
201 Created
```

```json
{
  "_response_info": { "status": "success" },
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
GET https://draft-assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/logo.png?token=<jwt-token>
```

If the access token is valid, the draft asset will be served. Otherwise, access will be denied.
Access tokens expire 30 days after they are issued or when asset is published, whichever occurs first. A new token can be regenerated using the `POST /assets/:id/regenerate-access` endpoint.

### Error responses

| Status                     | Description                           |
| -------------------------- | ------------------------------------- |
| `401 Unauthorized`         | Authentication failed.                |
| `413 Payload Too Large`    | Uploaded file exceeds permitted size. |
| `422 Unprocessable Entity` | Asset could not be created.           |


## Get asset information

Returns metadata for an asset.

### Request

```http
GET /assets/{asset-id}
```

### Success response

```json
{
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "asset_id": "6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": false
}
```

Replaced (superseded) assets will include `replacement_id`:

```json
{
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "asset_id": "6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": false,
  "replacement_id": "7a216e0509c4d5e2e98bd842"
}
```

### Error responses

| Status          | Description                                        |
| --------------- | -------------------------------------------------- |
| `403 Forbidden` | You don't have permission to access this resource. |
| `404 Not Found` | Asset does not exist.                              |


## Download asset

Returns the binary contents of an asset.

### Request

```http
GET /assets/{asset-id}/download
```

### Success response

```http
200 OK
```

Binary file content.

### Error responses

| Status          | Description             |
| --------------- | ----------------------- |
| `403 Forbidden` | You don't have permission to access this resource. |
| `404 Not Found` | Asset does not exist.   |
| `410 Gone`      | Asset has been deleted. |


## Regenerate draft asset access

Resets and generates a new preview link for a draft asset and returns an updated preview URL.

Draft asset access tokens expire 30 days after they are issued. Use this endpoint to generate a new token when the existing token has expired or is about to expire.

The response includes a refreshed `file_url` containing the new token and an updated `preview_expiry` timestamp.
This operation will disable the previous preview link.

### Request

```http
POST /assets/{asset-id}/regenerate-access
```

### Path parameters

| Parameter  | Description                     |
| ---------- | ------------------------------- |
| `asset-id` | Unique identifier of the asset. |

### Success response

```http
201 Created
```

```json
{
  "_response_info": { "status": "success" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "asset_id": "6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "file_url": "https://draft-assets.publishing.service.gov.uk/media/6a216e0509c4d5e2e98bd731/logo.png?token=eyJhbGciOiAIUzI1PiJ9.eyJzdWIiOiJkYmU3NmNiZC1kNmUjLTQzODItODA4OC01NDdkZGZiMzcwMWUiLCJjb250ZW50X2lkIjoiMmU0MDU3NTQtNTI1ZS00MjQ2LWJmZjgtYmI4ZjkwNzBiNTM4IiwiaWF0IjoxNzgxMDgxMjEwLCJleHAiOjE3ODM2NzMyMHB9.Uvqe1aHgGp_wxCTIyXMNB8COwBo9frs2l2SskZTBJ_Q",
  "preview_expiry": "2026-08-10T08:31:14Z"
}
```

### Error responses

| Status                     | Description                           |
| -------------------------- | ------------------------------------- |
| `401 Unauthorized`         | Authentication failed.                |
| `404 Not Found`            | Asset does not exist.                 |
| `422 Unprocessable Entity` | Access couldn't be regenerated        |


## Delete asset

Marks an asset as deleted.

### Request

```http
DELETE /assets/{asset-id}
```

### Success response

```http
200 OK
```

```json
{
  "_response_info": { "status": "success" },
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "name": "updated-logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/updated-logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": true
}
```

### Error responses

| Status          | Description                                   |
| --------------- | --------------------------------------------- |
| `404 Not Found` | Asset does not exist.                         |


## Restore deleted asset

Restores a previously deleted asset.

### Request

```http
PATCH /assets/{asset-id}/restore
```

### Success response

```http
200 OK
```

```json
{
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": false
}
```

### Error responses

| Status          | Description                      |
| --------------- | -------------------------------- |
| `404 Not Found` | Asset does not exist.            |
| `409 Conflict`  | Asset is already published.      |


## Update asset

Updates an existing asset. This endpoint supports multiple update operations including:

- publishing a draft asset
- replacing the file
- linking a replacement asset

All fields are optional, but at least one must be provided.

This is a partial update operation so only the attributes included in the request will be changed.

### Request

```http
PUT /assets/{asset-id}
Content-Type: multipart/form-data
```

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

### Success response

```http
200 OK
```

```json
{
  "id": "http://www.example.com/assets/6a216e0509c4d5e2e98bd731",
  "asset_id": "6a216e0509c4d5e2e98bd731",
  "name": "logo.png",
  "content_type": "image/png",
  "size": 82328,
  "file_url": "https://assets.publishing.service.gov.uk/media/659bee95614fa20014f3a9f7/logo.png",
  "state": "uploaded",
  "draft": false,
  "deleted": false
}
```

Replaced (superseded) assets will include `replacement_id`.

### Error responses

| Status                     | Description               |
| -------------------------- | ------------------------- |
| `404 Not Found`            | Asset does not exist.     |
| `422 Unprocessable Entity` | Asset update failed.      |


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
