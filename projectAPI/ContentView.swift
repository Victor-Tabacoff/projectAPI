//
//  ContentView.swift
//  APIProjectActual
//
//  Created by Victor B. Tabacoff on 9/25/24.
//

import SwiftUI

struct ContentView: View {
    @State private var pokemon: Pokemon?
    @State private var pokemonName: String = ""
    
    var body: some View {
        VStack {
            TextField("Enter Pokémon name", text: $pokemonName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    Task {
                        await fetchPokemon()
                    }
                }
            Spacer().frame(height: 20)
            if let pokemon = pokemon {
                AsyncImage(url: URL(string: pokemon.sprites.frontDefault)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.red, lineWidth: 4))
                } placeholder: {
                    Circle()
                        .foregroundColor(.secondary)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                }
                .frame(width: 150, height: 150)
                .shadow(radius: 5)
                Text(pokemon.name.capitalized)
                    .bold()
                    .font(.title2)
                    .padding(.top, 10)
                let cmHeight = pokemon.height * 10
                let kgWeight = pokemon.weight / 10
                let rkgWeight = pokemon.weight % 10
                VStack(alignment: .leading, spacing: 8) {
                    Text("ID: Pokémon #\(pokemon.id)")
                    Text("Height: \(cmHeight) cm")
                    Text("Weight: \(kgWeight).\(rkgWeight) kg")
                }
                .padding(.top, 20)
                .font(.body)
            } else {
                Text("Enter a valid Pokémon name to see its details.")
                    .foregroundColor(.gray)
                    .italic()
                    .padding(.top)
            }
Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    func fetchPokemon() async {
        guard !pokemonName.isEmpty else { return }
        do {
            pokemon = try await getPokemon(named: pokemonName.lowercased())
        } catch {
            print("Error fetching Pokémon: \(error)")
        }
    }
    func getPokemon(named name: String) async throws -> Pokemon {
        let endpoint = "https://pokeapi.co/api/v2/pokemon/\(name)"
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Pokemon.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
}

struct Pokemon: Codable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: Sprites

    struct Sprites: Codable {
        let frontDefault: String
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
