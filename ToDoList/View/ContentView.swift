//
//  ContentView.swift
//  ToDoList
//
//  Created by Kevin Kho on 09/09/20.
//  Copyright © 2020 Kevin Kho. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    // MARK: - PROPERTIES
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Todo.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Todo.name, ascending: true)]) var todos: FetchedResults<Todo>
    @State private var showingAddToDoView: Bool = false
    @State private var animatingButton: Bool = false
    
    var hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    // MARK: - BODY
    var body: some View {
        NavigationView{
            ZStack {
                List {
                    ForEach(self.todos, id: \.self) {todo in
                        HStack {
                            Circle()
                                .frame(width: 12, height: 12, alignment: .center)
                                .foregroundColor(self.colorize(priority: todo.priority ?? "Normal"))
                            Text(todo.name ?? "Unknown")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text(todo.priority ?? "Unknown")
                                .font(.footnote)
                                .foregroundColor(Color(UIColor.systemGray2))
                            .padding(3)
                                .frame(minWidth: 62)
                            .overlay(
                                Capsule().stroke(Color(UIColor.systemGray2), lineWidth: 0.75)
                            )
                        }// End: HStack
                            .padding(.vertical, 10)
                    }//End: Foreach
                    .onDelete(perform: deleteTodo)
                }//End: List
                    .navigationBarTitle(Text("To Do List"))
                    .navigationBarItems(
                        trailing: EditButton()
                        
                )
                // MARK: - NO TODO ITEMS
                if todos.count == 0 {
                    EmptyListView()
                }
            }//End: ZStack
            .sheet(isPresented: $showingAddToDoView) {
            AddToDoView().environment(\.managedObjectContext, self.managedObjectContext)
            }
            .overlay(
                ZStack {
                    Group {
                        Circle()
                            .fill(Color.blue)
                            .opacity(self.animatingButton ?  0.2 : 0)
                            .scaleEffect(self.animatingButton ? 1 : 0)
                            .frame(width: 68, height: 68, alignment: .center)
                        Circle()
                            .fill(Color.blue)
                            .opacity(self.animatingButton ? 0.15 : 0)
                            .scaleEffect(self.animatingButton ? 1 : 0)
                            .frame(width: 88, height: 88, alignment: .center)
                    }
                    .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true))
                    Button(action: {
                        self.showingAddToDoView.toggle()
                        self.hapticImpact.impactOccurred()
                    }) {
                        Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                            .background(Circle().fill(Color("ColorBase")))
                            .frame(width: 48, height: 48, alignment: .center)
                    }// End: Button
                        .onAppear(perform: {
                            self.animatingButton.toggle()
                        })
                }// End: ZStack
                    .padding(.bottom, 15)
                    .padding(.trailing, 15)
                , alignment: .bottomTrailing
            )
        }//End: NavigationView
    }
    
    // MARK: - FUNCTIONS
    private func deleteTodo(at offsets: IndexSet) {
        for index in offsets {
            let todo = todos[index]
            managedObjectContext.delete(todo)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    private func colorize(priority: String) -> Color {
        switch priority {
        case "High":
            return .red
        case "Normal":
            return .green
        case "Low":
            return .blue
        default:
            return .gray
        }
    }
}

// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView()
            .environment(\.managedObjectContext, context)
    }
}
