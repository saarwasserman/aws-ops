
# Overview

This project's goal, at least the initial one, is to create a kubernetes environment
on aws using eks for a stable, rich and fun software development.
It uses istio for gateway (supporting k8s gateway api)

## Current Status:
the eks cluster is created and istio is installed to be used for the gateway using k8s gateway api
and aws-load-balancer-controller.

The routing to and between service can be done using the k8s gateway api resources HttpRoute and a like.
Later, as istio is installed we can leverage a service mesh (either sidescar or ambient mode)
