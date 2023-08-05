#include <iostream>
#include <iterator>
#include <string>
#include <regex>

// Penadillo Lazares Wenses Johan 20182174D

using namespace std;

string add(string num1, string num2)
{
  if (num1.length() > num2.length())
    return add(num2, num1);

  int diff = num2.length() - num1.length();

  string padding;
  for (int i = 0; i < diff; i++)
    padding.push_back('0');

  num1 = padding + num1;
  string res;
  char carry = '0';

  for (int i = num1.length() - 1; i >= 0; i--)
  {
    if (num1[i] == '1' && num2[i] == '1')
    {
      if (carry == '1')
        res.push_back('1'), carry = '1';
      else
        res.push_back('0'), carry = '1';
    }
    else if (num1[i] == '0' && num2[i] == '0')
    {
      if (carry == '1')
        res.push_back('1'), carry = '0';
      else
        res.push_back('0'), carry = '0';
    }
    else if (num1[i] != num2[i])
    {
      if (carry == '1')
        res.push_back('0'), carry = '1';
      else
        res.push_back('1'), carry = '0';
    }
  }

  if (carry == '1')
    res.push_back(carry);
  reverse(res.begin(), res.end());

  int index = 0;
  while (index + 1 < res.length() && res[index] == '0')
    index++;
  return (res.substr(index));
}

string mul(string num1, string num2)
{
  if (num1.length() < num2.length())
    return mul(num2, num1);

  string res1, res2 = "0";

  int c = 0;
  for (int j = num2.length() - 1; j >= 0; j--)
  {
    res1 = "";
    for (int i = num1.length() - 1; i >= 0; i--)
    {
      if (num1[i] == '0' || num2[j] == '0')
      {
        res1.push_back('0');
      }
      else
      {
        res1.push_back('1');
      }

      string padding;
      for (int k = 0; k < c; k++)
        padding.push_back('0');
      res1 = res1 + padding;
      c++;
    }
    res2 = add(res2, res1);
  }

  return (res2);
}

bool verifyNumbers(string num1, string num2)
{
  regex binNum = regex("(1|0)+");
  bool res1 = regex_match(num1, binNum);
  bool res2 = regex_match(num2, binNum);
  return res1 && res2;
}

int main()
{
  string num1, num2;
  cout << "Operaciones con numeros binarios" << endl;
  cout << "Ingrese primer numero: ";
  cin >> num1;
  cout << "Ingrese segundo numero: ";
  cin >> num2;

  if (verifyNumbers(num1, num2))
  {
    cout << "Suma de numeros: " << add(num1, num2) << endl;
    cout << "Multiplicacion de numeros: " << mul(num1, num2) << endl;
  }
  else
  {
    cout << "Uno de los numeros ingresados no es binario";
  }

  return 0;
}
