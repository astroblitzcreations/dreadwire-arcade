#!/usr/bin/env python3
"""Fullscreen pygame display for discovering stable joystick axes/buttons."""

import sys
import pygame

pygame.init()
pygame.joystick.init()
screen = pygame.display.set_mode((0, 0), pygame.FULLSCREEN)
font = pygame.font.Font(None, 34)
clock = pygame.time.Clock()
joysticks = [pygame.joystick.Joystick(i) for i in range(pygame.joystick.get_count())]
for joystick in joysticks:
    joystick.init()

while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT or event.type == pygame.KEYDOWN:
            pygame.quit()
            raise SystemExit

    screen.fill((8, 10, 18))
    lines = ["DREADWIRE CONTROLLER TEST", "Hold Start + Select to exit", ""]
    exit_requested = False
    for number, joystick in enumerate(joysticks):
        axes = [round(joystick.get_axis(i), 2) for i in range(joystick.get_numaxes())]
        pressed = [i for i in range(joystick.get_numbuttons()) if joystick.get_button(i)]
        lines += [f"Controller {number}: {joystick.get_name()}",
                  f"GUID: {joystick.get_guid()}", f"Axes: {axes}",
                  f"Pressed buttons: {pressed}", ""]
        if 4 in pressed and 5 in pressed:
            exit_requested = True
    if not joysticks:
        lines += ["No SDL controller found.", "Install tools first if pygame is missing."]

    y = 32
    for line in lines:
        screen.blit(font.render(line, True, (235, 242, 255)), (32, y))
        y += 38
    pygame.display.flip()
    if exit_requested:
        pygame.quit()
        sys.exit(0)
    clock.tick(30)

