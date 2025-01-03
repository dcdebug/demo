package main

import (
	"fmt"
	"sync"
	"time"
)

func f(from string) {
	for i := 0; i < 4; i++ {
		fmt.Println(from, ",from:", i)
	}
}

func main() {
	f("direct")
	go f("goroutines")

	go func(msg string) {
		fmt.Println(time.Now().Format("2006-01-02 15:04:05"), msg)
	}("going--going--going")

	time.Sleep(time.Second)
	fmt.Println("done...")
	//waitGroup.
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Println("I'm a GoRoutines.....")

	}()
	wg.Wait()
	fmt.Println("main func end....")
	return
}
