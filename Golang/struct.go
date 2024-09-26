package main

import "fmt"
type Person struct {
		First_Name string
		Last_Name string
		Age  int
		
}

func main(){
		p1 := Person{ First_Name: "eaaa",Last_Name: "Wong", Age: 35}
		fmt.Print(p1);
}
