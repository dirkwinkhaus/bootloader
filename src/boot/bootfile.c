void main ()
{
	print("huhu", 0x07);
}

void print(char * string, int color)
{
    char * videoMemory = (char *) (0xb8000);

    while (*string != 0) {
        *videoMemory = *string;
        videoMemory++;
        string++;
        *videoMemory = color;
        videoMemory++;
    }
}
