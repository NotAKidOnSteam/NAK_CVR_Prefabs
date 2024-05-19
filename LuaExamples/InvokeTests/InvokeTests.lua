-- Start is called 3 seconds after being in the world
function Start()
    if not this then return end

    -- Delay the start by 3 seconds
    this.InvokeFunction("BeginInvokes", 3.0)
end

function BeginInvokes()
    -- Example of InvokeFunction with no arguments
    -- Immediately invokes the TestInvokeFunction1 function
    this.InvokeFunction("TestInvokeFunction1")

    -- Example of InvokeFunction with arguments
    -- Immediately invokes the TestInvokeFunction2 function with the argument "Hello from Lua!"
    this.InvokeFunction("TestInvokeFunction2", "Hello from Lua!")

    -- Example of InvokeFunction with a delay and arguments
    -- Invokes the TestInvokeFunction3 function after a 1.5-second delay with the argument "Hello after delay!"
    this.InvokeFunction("TestInvokeFunction3", 1.5, "Hello after delay!")

    -- Example of InvokeFunctionRepeating with a delay, repeat rate, and repeat count
    -- Invokes the TestInvokeFunction4 function after a 1-second delay, then repeats every 0.5 seconds, a total of 5 times with the argument "Repeating message"
    this.InvokeFunctionRepeating("TestInvokeFunction4", 1.0, 0.5, 5, "Repeating message")

    -- Example of InvokeFunctionRepeating with a delay, repeat rate, and repeat count
    -- Invokes the TestInvokeFunction5 function after a 2-second delay, then repeats every 1 second indefinitely
    this.InvokeFunctionRepeating("TestInvokeFunction5", 2.0, 1.0, -1)

    -- Invoke the CancelAllInvokes function after a 10-second delay to cancel all invokes
    this.InvokeFunction("CancelAllInvokes", 10.0)
end

-- Function to be invoked (no arguments)
function TestInvokeFunction1()
    print("TestInvokeFunction1 called")
end

-- Function to be invoked (with arguments)
function TestInvokeFunction2(message)
    print("TestInvokeFunction2 called with message: " .. message)
end

-- Function to be invoked (with delay and arguments)
function TestInvokeFunction3(message)
    print("TestInvokeFunction3 called after delay with message: " .. message)
end

-- Repeating function with arguments
function TestInvokeFunction4(message)
    print("TestInvokeFunction4 repeating with message: " .. message)
end

-- Repeating function with default repeat rate and repeat count
function TestInvokeFunction5()
    print("TestInvokeFunction5 repeating with default parameters")
end

-- Function to cancel all invokes
function CancelAllInvokes()
    if not this then return end

    print("CancelAllInvokes called, stopping all scheduled invokes")
    this.CancelAllInvokeFunctions()
end
