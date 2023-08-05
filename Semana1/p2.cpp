#include <iostream>
#include <iterator>
#include <string>
#include <regex>

// Penadillo Lazares Wenses Johan 20182174D

using namespace std;

int main()
{
  string dni, codigo, nombre, numero;
  cout << "Ingrese DNI: ";
  cin >> dni;

  regex reDNI = regex("[0-9]{8}");
  if (regex_match(dni, reDNI))
  {
    cout << "DNI valido" << endl;
  }
  else
  {
    cout << "DNI invalido" << endl;
  }

  cout << "Ingrese un codigo (0AC01F max 6 char): ";
  cin >> codigo;

  regex reCodigo = regex("^0([A-Z]|0|1){5}");
  if (regex_match(codigo, reCodigo))
  {
    cout << "Codigo valido" << endl;
  }
  else
  {
    cout << "Codigo invalido" << endl;
  }

  cout << "Ingrese un nombre (max 100 char): ";
  cin >> nombre;

  regex reNombre = regex("\\w{1,100}");
  if (regex_match(nombre, reNombre))
  {
    cout << "Nombre valido" << endl;
  }
  else
  {
    cout << "Nombre no valido" << endl;
  }

  cout << "Ingrese un numero (miles con espacios): ";
  cin >> numero;

  regex reNumero = regex("^[1-9]\\d{0,2}(\\s\\d{3})*");
  if (regex_match(numero, reNumero))
  {
    cout << "Numero valido" << endl;
  }
  else
  {
    cout << "Numero no valido" << endl;
  }

  return 0;
}
