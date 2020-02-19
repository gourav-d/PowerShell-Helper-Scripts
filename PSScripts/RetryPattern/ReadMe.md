# How to use:



## Positive Test Case

    RetryCommand -Command { 
        
        Write-Host "Hello World!!!"

    } -MaxRetry 3



## Negative Test Case

    RetryCommand -Command { 
        
        Write-Host "Exception is going to occur"
        throw 'logic throw exception'

    } -MaxRetry 3 -RetryDelay 2 -ExceptionCallBack {
        param($exception)
        Write-ErrorLog "Here is your exception info:: $($exception.Message)"
    }


### Note: 
   *RetryDelay(in seconds) and ExceptionCallBack are optional parameters. ExceptionCallBack parameter is recommended when you need to log or capture the exception.*