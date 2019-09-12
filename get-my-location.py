import sys
import argparse

parser = argparse.ArgumentParser(description="Get localization of my phone using google API")

parser.add_argument('-t',                \
                    dest='token',        \
                    action='store_true', \
                    help='Token is needed to contact with google API',\
                    required=True)

def basicCheck():
    parser.print_help()
    sys.exit(1)

def main():
    basicCheck()
    pass

if __name__ == '__main__':
    main()
