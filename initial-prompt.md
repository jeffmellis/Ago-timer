i want to create a watchOS app like the built in stopwatch app, but with more features.
at its core, we need a stopwatch that shows hours,minutes,seconds,milliseconds, like the current one does. we need start and pause functionality.

i also want:
1. multiple stopwatchs. you should be able to swipe over to start a new stopwatch, and then swipe back and forth between each of the stopwatchs you have started. so it shows all stopwatchs and the last screen available is the ability to start a new one.
2. the ability to edit a stopwatch. so you can start it from 1 min and 5 seconds for example. or if its running, you can pause it and then edit it to add an extra minute. This case is important because sometimes i forget to start my stopwatch, but i know its been about 3 minutes, so i want to be able to edit it and start it from 3 minutes instead of 0. Also sometimes my stopwatch gets paused randomly and i want to edit the time and then start running it again
3. when the stopwatch is paused, it should display the time that it was paused at. this will help me with starting the stopwatch again if it randomly gets paused by graising the button or something.

so lets make the core stopwatch, then work on each of the improvements. 