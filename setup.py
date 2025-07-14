from setuptools import setup, find_packages

setup(
    name="random-choice-app",
    version="0.1",
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        "customtkinter",
    ],
    entry_points={
        'gui_scripts': [
            'random-choice-app=random_choice.main:main',
        ],
    },
    package_data={
        '': ['assets/*.ico'],
    },
    author="Feriel080",
    author_email="aourferiel22@outlook.com",
    description="A simple GUI application for making random choices.",
    license="MIT",
    keywords="random choice gui",
    url="https://github.com/Feriel080/RandomChoice",
)