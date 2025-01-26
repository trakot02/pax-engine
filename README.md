# Pax engine

Work in progress...

## Layers

An application is divided in one or more layers responsible for their resources and activities. Toghether the layers form a stack that determines the order in which the layers execute. Every frame the application repeats the following steps:

1. For each event, each layer reacts to it
2. Each layer updates its state
3. Each layer renders its content

The update and reaction steps are executed from top to bottom, while the rendering happens in reverse order. The reaction step has also another feature: when a layer receives an event, it can decide to prevent the lower layers from receiving it. A layer can finally skip any of steps by setting dedicated attributes.

The stack can therefore be manipulated by adding or removing layers from the top, but a layer can also be forced to the bottom of the stack to expel every other layer and pause their execution.
