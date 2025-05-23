#include <bits/stdc++.h>
using namespace std;
using ll = long long;
#define setbits(x) __builtin_popcountll(x)
mt19937_64 rng(chrono::steady_clock::now().time_since_epoch().count());
ll random_num(ll l = 0, ll r = (1LL << 40) - 1) {
    uniform_int_distribution<ll> uid(l, r);
    return uid(rng);
}
#define binstr(n, x) bitset<n>(x).to_string()
const ll horiz = (1LL << 20) - 1;
const ll vert = ((1LL << 40) - 1) ^ ((1LL << 20) - 1);
const int N = 7000; // Updated to 7000

int main() {
    ifstream infile("test_cases.txt");
    ofstream outfile("test_cases_new.txt");

    if (!infile || !outfile) {
        cerr << "Error opening file!" << endl;
        return 1;
    }

    set<ll> existing_cases;
    set<ll> new_cases;

    // Load existing test cases into the set
    string line;
    while (getline(infile, line)) {
        if (line.empty()) continue;
        ll num = stoll(line, nullptr, 2); // Convert binary string to number
        existing_cases.insert(num);
    }
    infile.close();

    // Generate new unique test cases
    while (new_cases.size() < N - existing_cases.size()) {
        ll num = random_num();
        if (existing_cases.count(num) || new_cases.count(num)) continue;

        ll hz = num & horiz, vt = num & vert;
        if (setbits(hz) < 10 || setbits(vert) < 10) continue;

        string ss = binstr(40, num);
        bool valid = true;
        for (int i = 0; i < 40; i += 5) {
            auto x = ss.substr(i, 5);
            if (x.find("000") != string::npos) {
                valid = false;
                break;
            }
        }
        if (!valid) continue;

        new_cases.insert(num);
        outfile << binstr(40, num) << '\n';
    }

    outfile.close();
    return 0;
}
