# Pax engine

Work in progress...

## Layers

An application is divided in one or more layers responsible for their resources and activities. During execution the layers form a stack that determines the order in which each one can perform its activities. Such stack can be manipulated by adding or removing layers from the top, but also by forcing a layer to the bottom to pause the execution of every other, that can be resumed at a later point.

Every frame the application repeats the following steps:

1. For each event, each layer in the stack reacts to it
2. Each layer in the stack updates its state
3. Each layer in the stack paints its content

The update and event steps are executed from top to bottom, while the painting happens in reverse order. The event step has also another feature: when a layer receives an event, it can decide to prevent the lower layers from receiving it. A layer can finally skip any of these steps by setting dedicated attributes.
