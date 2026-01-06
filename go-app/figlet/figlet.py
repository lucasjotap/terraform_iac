import os
import subprocess

from pyfiglet import Figlet


class FigletDisplay:

	def __init__(self font: str):
		self.font = Figlet(font=font)
		self.fav_kernel = os.sys.platform

	def display_figlet(self) -> None:
		try:
			print("What's your favorite kernel?")
			print(self.font.renderText(self.fav_kernel))
		except Exception as e:
			print(e)
			return None
		return None


if __name__ == "__main__":
	fd = FigletDisplay("slant")
	fd.display_figlet()

