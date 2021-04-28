package main

import (
	"flag"
	"fmt"
	"github.com/gin-contrib/static"
	"github.com/gin-gonic/gin"
	"golang.org/x/sync/errgroup"
	"net/http"
	"os"
	"log"
	"time"
	"strconv"
	// "crypto/tls"
)

var (
    g errgroup.Group
)

func fileExists(filename string) bool {
	info, err := os.Stat(filename)
	if os.IsNotExist(err) {
		return false
	}
	return !info.IsDir()
}

func router80() http.Handler {
	router := gin.New()
	router.Use(gin.Logger())

	// Recovery middleware recovers from any panics and writes a 500 if there was one.
	router.Use(gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
		if err, ok := recovered.(string); ok {
			c.String(http.StatusInternalServerError, fmt.Sprintf("error: %s", err))
		}
		c.AbortWithStatus(http.StatusInternalServerError)
	}))

	// Serve Static files for UE
	router.Use(static.Serve("/", static.LocalFile("/tmp", false)))

	// Create dummy files to downlaod by UEs
	router.POST("/create", func(c *gin.Context) {
		mb := c.DefaultQuery("mb", "1")
		fileName := c.DefaultQuery("file", fmt.Sprintf("%smb.txt", mb))
		fmt.Printf("mb: %s; file: %s", mb, fileName)
		newFileName := fmt.Sprintf("/tmp/%s", fileName)

		if fileExists(newFileName) {
			fmt.Println("%s alreay exists", newFileName)
		} else {
			fmt.Printf("%s is not present, creating it", newFileName)
			fd, err := os.Create(fmt.Sprintf("/tmp/%s", fileName))
			if err != nil {
				panic(err)
			}

			intMb, _ := strconv.Atoi(mb)
			size := int64(intMb * 1024 * 1024)
			_, err = fd.Seek(size-1, 0)
			if err != nil {
				panic(err)
			}

			_, err = fd.Write([]byte{0})
			if err != nil {
				panic(err)
			}

			err = fd.Close()
			if err != nil {
				panic(err)
			}
		}

	})

	return router
}

func router443() http.Handler {
	router := gin.New()
	router.Use(gin.Logger())

	// Recovery middleware recovers from any panics and writes a 500 if there was one.
	router.Use(gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
		if err, ok := recovered.(string); ok {
			c.String(http.StatusInternalServerError, fmt.Sprintf("error: %s", err))
		}
		c.AbortWithStatus(http.StatusInternalServerError)
	}))

	// Serve Static files for UE
	router.Use(static.Serve("/", static.LocalFile("/tmp", false)))

	return router
}

func main() {

	var http_listen = flag.String("http_listen", "0.0.0.0:80", "HTTP server port")
	var https_listen = flag.String("https_listen", "0.0.0.0:443", "HTTP server port")
	flag.Parse()

    server80 := &http.Server{
        Addr:         *http_listen,
        Handler:      router80(),
        ReadTimeout:  5 * time.Second,
        WriteTimeout: 10 * time.Second,
    }

    // cfg := &tls.Config{
    //     MinVersion:               tls.VersionTLS12,
    //     CurvePreferences:         []tls.CurveID{tls.CurveP521, tls.CurveP384, tls.CurveP256},
    //     PreferServerCipherSuites: true,
    //     CipherSuites: []uint16{
    //         tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
    //         tls.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,
    //         tls.TLS_RSA_WITH_AES_256_GCM_SHA384,
    //         tls.TLS_RSA_WITH_AES_256_CBC_SHA,
    //     },
    // }

    server443 := &http.Server{
        Addr:         *https_listen,
        Handler:      router443(),
        ReadTimeout:  5 * time.Second,
        WriteTimeout: 10 * time.Second,
    }

    g.Go(func() error {
        return server80.ListenAndServe()
    })

    g.Go(func() error {
        return server443.ListenAndServeTLS("./server.crt", "./server.key")
    })

    if err := g.Wait(); err != nil {
        log.Fatal(err)
    }
}
