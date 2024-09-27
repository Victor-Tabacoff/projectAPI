//
//  ContentView.swift
//  APIProjectActual
//
//  Created by Victor B. Tabacoff on 9/25/24.
//

import SwiftUI

struct ContentView: View {
    @State private var pokemon: Pokemon?
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: pokemon?.sprites.frontDefault ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.circle)
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 150, height: 150)
            Text(pokemon?.name.capitalized ?? "Name Placeholder")
                .bold()
                .font(.title3)
            Text("ID: Pokemon #\(pokemon?.id ?? 0)")
            Text("Height: \(pokemon?.height ?? 0) decimeters")
            Text("Weight: \(pokemon?.weight ?? 0) hectograms")
        }
        .padding()
        .task {
            do {
                pokemon = try await getPokemon()
            } catch {
                print("Error fetching Pokémon: \(error)")
            }
        }
    }
    func getPokemon() async throws -> Pokemon {
        let endpoint = "https://pokeapi.co/api/v2/pokemon/ditto"
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
