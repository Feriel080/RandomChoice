import customtkinter as ctk
import random
import os
import time
import platform
import subprocess
import sys

def resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")

    return os.path.join(base_path, relative_path)


ctk.set_appearance_mode("light")
ctk.set_default_color_theme("blue")

window = ctk.CTk(fg_color="white")
window.title("Random Choice")
window.geometry("300x300")
window.resizable(False, False)
window.iconbitmap(resource_path("assets/random.ico"))

filename = "list_of_choices.txt"
filepath = f"{filename}"
list_of_choices = []


def createList():
    global list_of_choices
    if not os.path.exists(filename):
        with open(filename, "w") as file:
            pass
    with open(filename, "r") as file:
        list_of_choices = file.read().splitlines()


createList()


def choose():
    if not list_of_choices:
        output_box.configure(
            text="there's nothing to choose",
            bg_color="#FEEFE3",
            text_color="#B31412",
        )

    else:
        output_box.configure(
            text=random.choice(list_of_choices),
            bg_color="#E0F2F1",
            text_color="#0E8573",
        )


def add():
    add_elem.place_forget()
    text_box.place(x=70, y=90)
    text_box.focus_set()
    enter.place(x=170, y=90)
    window.bind(
        "<Escape>",
        lambda event: (
            text_box.place_forget(),
            enter.place_forget(),
            add_elem.place(x=80, y=80),
        ),
    )


def submit():
    thing = text_box.get()
    text_box.delete(0, ctk.END)
    exist_or_saved = ctk.CTkLabel(
        window,
        bg_color="transparent",
        width=75,
        height=30,
        corner_radius=30,
    )

    if thing in list_of_choices:
        exist_or_saved.configure(text=f"{thing} already exists!", text_color="red")
        exist_or_saved.place(x=80, y=120)
        text_box.place_forget()
        enter.place_forget()
        add_elem.place(x=80, y=90)
        window.after(2000, exist_or_saved.place_forget)
        return

    else:
        with open(filename, "a") as file:
            file.write(thing + "\n")

        exist_or_saved.configure(
            text=f"'{thing}' added successfully", text_color="#0E8573"
        )
        exist_or_saved.place(x=70, y=120)
        window.after(2000, exist_or_saved.place_forget)

        text_box.place_forget()
        enter.place_forget()
        add_elem.place(x=80, y=90)
        createList()


output_box = ctk.CTkLabel(
    window,
    text="",
    bg_color="#E0E0E0",
    wraplength=280,
    width=280,
    height=100,
    corner_radius=15,
    font=("sans-serif", 16),
)
output_box.place(x=10, y=150)

btn = ctk.CTkButton(
    window, text="Choose a thing to do", command=choose, width=150, height=30
)
btn.place(x=80, y=50)

add_elem = ctk.CTkButton(
    window,
    text="Add a thing",
    command=add,
    width=150,
    height=30,
    fg_color="#0E8573",
    text_color="white",
    hover_color="#0B6B5A",
)
add_elem.place(x=80, y=90)

text_box = ctk.CTkEntry(window, width=80, height=30)
enter = ctk.CTkButton(
    window,
    text="Save",
    command=submit,
    width=75,
    height=30,
    fg_color="#B39DDB",
    hover_color="#9575CD",
    text_color="white",
)

def open_file():
    if os.path.exists(filepath):
        if platform.system() == 'Windows':
            os.startfile(filepath)
            time.sleep(10)
        
        elif platform.system() == 'Darwin':
            process = subprocess.Popen(['open', filepath])
            process.wait()
            
        else:
            process = subprocess.Popen(['xdg-open', filepath])
            process.wait()
            
    else:
        createList()
    
    createList()


open_list = ctk.CTkButton(
    window,
    text="view list",
    command=open_file,
    width=75,
    height=30,
    fg_color="transparent",
    text_color="black",
    font=("sans-serif", 13, "underline"),
    hover_color="#CFCFCF",
)
open_list.place(x=5, y=5)

window.mainloop()
