#!/usr/local/lib/python3.8

import json

print('Initiating conversion')

inventory_old = open('../inventory.bar', "r")

inventory_old = json.load(inventory_old)
empty = []

for machines in inventory_old:
    empty.append(list(machines.values()))

inventory = open("inventory.txt", "w")
inventory.write("[services]\n")

for id, ip in enumerate(empty):
    inventory.write(f"machine-{id}    {ip[0]} \n")