package main

import (
	"bufio"
	"fmt"
	"github.com/kr/logfmt"
	"os"
)

func main() {
	reader := bufio.NewScanner(os.Stdin)
	for reader.Scan() {
		line := reader.Text()
		handler := NewHandler()
		logfmt.Unmarshal([]byte(line), handler)
		fmt.Printf("%+v\n", handler.Entry)
	}
	fmt.Println("OK")
}
