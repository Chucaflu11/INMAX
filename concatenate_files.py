import os

def is_important_file(filepath):
    """Checks if a file is important based on its extension and directory."""
    if os.path.basename(filepath) in ['Dockerfile', 'docker-compose.yml']:
        return True
    
    name, ext = os.path.splitext(filepath)
    if ext in ['.py', '.js', '.dart']:
        # Exclude files in specified directories
        excluded_dirs = ['node_modules', 'android', 'build', 'web', 'test', '.idea', '.dart_tool']
        for excluded_dir in excluded_dirs:
            if excluded_dir in filepath:
                return False
        return True
    return False

def concatenate_important_files(output_filename="concatenated_code.txt"):
    """Concatenates important project files into a single file."""
    with open(output_filename, "w") as outfile:
        for root, _, files in os.walk("."):
            for filename in files:
                filepath = os.path.join(root, filename)
                if is_important_file(filepath):
                    try:
                        with open(filepath, "r") as infile:
                            outfile.write(f"# {filepath}\n")
                            outfile.write(infile.read())
                            outfile.write("\n\n")  # Add some space between files
                    except Exception as e:
                        print(f"Error reading file {filepath}: {e}")

if __name__ == "__main__":
    concatenate_important_files()
    print(f"Important files concatenated into concatenated_code.txt")
