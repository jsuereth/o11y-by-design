package o11y

import (
	"context"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"
)

// DO NOT MODIFY: This code is autogenerated.
// See templates/registry/go/metric.go.j2.

type AuctionBidCountAttributes struct {

	// The id of the auction.
	AuctionId int
}

func (attrs AuctionBidCountAttributes) asMeasurementOptions() metric.MeasurementOption {
	return metric.WithAttributes(

		attribute.Int("auction.id", attrs.AuctionId),
	)
}

// An instrument for recording `auction.bid.count`
type AuctionBidCount interface {

	// Adds to the current count.
	Add(context.Context, AuctionBidCountAttributes, float64)
}

// Construct a new instrument for measuring `auction.bid.count`
func NewAuctionBidCount(m metric.Meter) (AuctionBidCount, error) {
	i, err := m.Float64Counter(
		"auction.bid.count",
		metric.WithDescription("Count of all bids we've seen"),
		metric.WithUnit("{bid}"),
	)
	if err != nil {
		return nil, err
	}
	return wrapperAuctionBidCount{&i}, nil
}

type wrapperAuctionBidCount struct {
	instrument *metric.Float64Counter
}

func (m wrapperAuctionBidCount) Add(ctx context.Context, attrs AuctionBidCountAttributes, inc float64) {
	(*m.instrument).Add(ctx, inc, attrs.asMeasurementOptions())
}
