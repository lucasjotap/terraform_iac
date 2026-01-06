package main

import (
	"io/ioutil"
	"log"
	"net/http"
	"fmt"
)

func main() {
	for i:= 0; i < 1000000; i++ {
		resp, err := http.Get("http://127.0.0.1:8080/api/v1/data")
		if err != nil {
			log.Fatalln(err)
		}

		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			log.Fatalln(err)
		}
		defer resp.Body.Close()
		fmt.Println(body)
	}
}
