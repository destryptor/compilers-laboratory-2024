#include <bits/stdc++.h>
using namespace std;
using ll = long long;
ll evalsum(string);
ll evalterm(string);
ll evalsum(string s)
{
    // cout << "Evalsum:" << s << '\n';
    if (s.empty())
        return 0;
    ll ans = 0;
    string sum;
    for(char& c : s) {
        if(c == '+') {
            ans += evalterm(sum);
            sum = "";
        } else {
            sum += c;
        }
    }
    ans += evalterm(sum);
    return ans;
}

ll evalterm(string s)
{
    // cout << "Evalterm:" << s << '\n';

    if (s.empty())
        return 0;
    ll ans = 1;
    string prod;
    for(char& c : s) {
        if(c == '*') {
            ans *= stoll(prod);
            prod = "";
        } else {
            prod += c;
        }
    }
    ans *= stoll(prod);
    return ans;
}

bool validExp(string& s) {
    int n = s.size();

    if(s[0] == '+' || s[0] == '*' || s.back() == '+' || s.back() == '*' || s[0] == ')' || s.back() == '(') return false;
    for(int i = 0; i < n - 1; i++) {
        if(s[i] == '+' && s[i + 1] == '+') return false;
        if(s[i] == '*' && s[i + 1] == '*') return false;
        if(s[i] == '+' && s[i + 1] == '*') return false;
        if(s[i] == '*' && s[i + 1] == '+') return false;
        if(s[i] == '(' && s[i + 1] == ')') return false;
    }
    return true;
}

int main()
{
    string input;
    string line;

    char arr[100000];
    fgets(arr, 100000, stdin);

    string filteredInput;

    for (int i = 0; i < 100000; i++)
    {
        if (arr[i] != ' ')
        {
            filteredInput += arr[i];
        }
        if (arr[i] == '\n')
            break;
    }

    int paranCnt = 0;
    for(char& c : filteredInput) {
        if(c == '(') paranCnt++;
        else if(c == ')') paranCnt--;

        if(paranCnt < 0) {
            cout << "Invalid arithmetic expression" << '\n';
            return 0;
        }
    }

    if(paranCnt != 0) {
        cout << "Invalid arithmetic expression" << '\n';
        return 0;
    }

    if(!validExp(filteredInput)) {
        cout << "Invalid arithmetic expression" << '\n';
        return 0;
    }

    // cout << filteredInput;
    ll ans = 0;
    stack<char> st;

    for(char& c : filteredInput) {
        if(c == ')') {
            string temp;
            while(st.top() != '(') {
                temp += st.top();
                st.pop();
            }
            st.pop();
            reverse(temp.begin(), temp.end());
            if(!validExp(temp)) {
                cout << "Invalid arithmetic expression" << '\n';
                return 0;
            }
            // cout << "Stack push: " << temp << '\n';
            ll val = evalsum(temp);
            string push;
            while(val) {
                push += to_string(val % 10);
                val /= 10;
            }
            reverse(push.begin(), push.end());
            for(char& ch : push) {
                st.push(ch);
            }
        } else {
            st.push(c);
        }
    }

    string fin;
    while(!st.empty()) {
        fin += st.top();
        st.pop();
    }
    reverse(fin.begin(), fin.end());

    // cout << fin << '\n';


    cout << evalsum(fin) << '\n';
}