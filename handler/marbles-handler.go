package handler

import (
	"golang.org/x/net/context"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"

	"github.com/govinda-attal/hf-client/pkg/ca"
	"github.com/govinda-attal/hf-client/pkg/channel"
	pb "github.com/govinda-attal/marbles-api/pkg"
)

// MarblesSrv ...
type MarblesSrv struct {
	CCID       string
	ChnlClient channel.Client
	CAClient   ca.Client
}

const (
	fcnTransferMarble = "transferMarble"
	fcnReadMarble     = "readMarble"
)

// Transfer(context.Context, *TransferMarbleRq) (*TransferMarbleRs, error)
// Fetch(context.Context, *FetchMarbleRq) (*FetchMarbleRs, error)

// Transfer ...
func (ms *MarblesSrv) Transfer(ctx context.Context, rq *pb.TransferMarbleRq) (*pb.TransferMarbleRs, error) {
	rs := pb.TransferMarbleRs{}
	return &rs, nil
}

// Fetch ...
func (ms *MarblesSrv) Fetch(ctx context.Context, rq *pb.FetchMarbleRq) (*pb.FetchMarbleRs, error) {
	rs := pb.FetchMarbleRs{}
	var rsMap map[string]interface{}
	rqArr := []interface{}{rq.Name}
	err := ms.ChnlClient.Execute(ctx, ms.CCID, fcnReadMarble, rqArr, nil, &rsMap)
	if err != nil {
		return nil, grpc.Errorf(codes.NotFound, err.Error())
	}
	rs.Name = rsMap["name"].(string)
	rs.Owner = rsMap["owner"].(string)
	rs.Size = int32(rsMap["size"].(float64))

	return &rs, nil
}
