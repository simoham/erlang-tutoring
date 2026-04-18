package main

import (
    "fmt"
    "log"
    "os"
)

func ls_dir(dir string) []os.DirEntry {
    entries, err := os.ReadDir(dir)
    if err != nil {
        log.Fatal(err)
	return nil
    }
    return entries
}

func loop(dir string, client chan string, res chan []os.DirEntry){
        for {
                select {
		case cmd := <- client:
			switch cmd {
			case "get_list":
				dir_list := ls_dir(dir)
				res <- dir_list
			}

                }
        }
}


func main(){
        var dir string
	dir="/etc"

        client_chan:=make(chan string)
	res_chan:=make(chan []os.DirEntry)

        go loop(dir, client_chan, res_chan)
	client_chan <- "get_list"
	files := <- res_chan

	for _, file := range files {
		fmt.Println(file.Name(), file.IsDir())
	}
}

