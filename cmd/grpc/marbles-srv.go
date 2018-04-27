package main

import (
	"flag"
	"fmt"
	"log"
	"net"

	"github.com/govinda-attal/hf-client/pkg/ca"
	"github.com/govinda-attal/hf-client/pkg/channel"
	"github.com/govinda-attal/hf-client/pkg/sdk"
	"google.golang.org/grpc"

	"github.com/govinda-attal/marbles-api/handler"
	pb "github.com/govinda-attal/marbles-api/pkg"
)

var (
	port = flag.Int("port", 10000, "The server port")

	tls      = flag.Bool("tls", false, "Connection uses TLS if true, else plain TCP")
	certFile = flag.String("certFile", "", "The TLS cert file")
	keyFile  = flag.String("keyFile", "", "The TLS key file")

	hfcConfigFile = flag.String("hfcConfigFile", "./config/config.yaml", "fabric blockchain config file")
	hfCCID        = flag.String("hfCCID", "marbles", "")
	hfChnlID      = flag.String("hfChnlID", "mychannel", "")
	hfOrgName     = flag.String("hfOrgName", "Org1", "")
	hfUserName    = flag.String("hfUserName", "Admin", "")
)

func newServer(ccID string, chClient channel.Client, caClient ca.Client) *handler.MarblesSrv {
	s := &handler.MarblesSrv{CCID: ccID, ChnlClient: chClient, CAClient: caClient}
	return s
}

func main() {
	flag.Parse()
	lis, err := net.Listen("tcp", fmt.Sprintf("localhost:%d", *port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	var opts []grpc.ServerOption
	// if *tls {
	// 	if *certFile == "" {+
	// 		*certFile = testdata.Path("server1.pem")
	// 	}
	// 	if *keyFile == "" {
	// 		*keyFile = testdata.Path("server1.key")
	// 	}
	// 	creds, err := credentials.NewServerTLSFromFile(*certFile, *keyFile)
	// 	if err != nil {
	// 		log.Fatalf("Failed to generate credentials %v", err)
	// 	}
	// 	opts = []grpc.ServerOption{grpc.Creds(creds)}
	// }
	sdk, err := sdk.NewFabSDK(*hfcConfigFile)
	if err != nil {
		log.Fatalf("Fatal error: %v", err)
	}
	defer sdk.Close()
	caClient, err := ca.New(sdk, *hfOrgName)
	if err != nil {
		log.Fatalf("Fatal error: %v", err)
	}
	log.Println("SOME INFO: ", *hfUserName)
	chClient, _ := channel.New(sdk, *hfChnlID, *hfOrgName, *hfUserName)
	if err != nil {
		log.Fatalf("Fatal error: %v", err)
	}
	grpcServer := grpc.NewServer(opts...)
	pb.RegisterMarblesServer(grpcServer, newServer(*hfCCID, chClient, caClient))
	grpcServer.Serve(lis)
}
