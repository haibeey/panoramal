# panoramaI

A light weight panoramal viewer targeting IOS.

## Usage 

###  If 360 image is in Resources folder.
```
import panoramaI


struct ContentView: View {
        
    var body: some View {
        VStack{
            PanoramaI(source: .namedFile(name:"merged", ext:"jpg"))
        }
    }
}

```

###  Load from url.
```
import panoramaI


struct ContentView: View {
        
    var body: some View {
        VStack{
             PanoramaI(source: .urlPath("https://url.com/360image.jpeg"))
        }
    }
}

```


## Quick demo


![paris](assets/demo.gif)    ![world view](assets/demo2.gif)

 
