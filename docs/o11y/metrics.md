# Produced Metrics


## Metric `auction.bid.count`

| Name     | Instrument Type | Unit (UCUM) | Description    | Stability |
| -------- | --------------- | ----------- | -------------- | --------- |
| `auction.bid.count` | Counter | `{bid}` | Count of all bids we've seen | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |


### Attributes

| Attribute  | Type | Description  | Examples  | [Requirement Level](https://opentelemetry.io/docs/specs/semconv/general/attribute-requirement-level/) | Stability |
|---|---|---|---|---|---|
| `auction.id` | int | The id of the auction. |  | `Required` | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |
| `auction.name` | string | The name of the auction | `Fish for sale` | `Recommended` | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |


