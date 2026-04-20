package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"time"
)

func main() {
	// Seed the random number generator
	rand.Seed(time.Now().UnixNano())

	// Create a buffered writer for stdout
	writer := bufio.NewWriter(os.Stdout)

	// Generate and output random numbers continuously
	for {
		// Generate random number between 1 and 1000
		randomNum := rand.Intn(1000) + 1

		// Write the number to stdout
		_, err := fmt.Fprintf(writer, "%d\n", randomNum)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error writing: %v\n", err)
			return
		}

		// Flush the buffer
		writer.Flush()

		// Wait a bit before generating next number
		time.Sleep(1 * time.Second)
	}
}
