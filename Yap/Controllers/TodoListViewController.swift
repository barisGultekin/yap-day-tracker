//
//  ViewController.swift
//  Yap
//
//  Created by Ali Barış Gültekin on 25.04.2021.
//

import UIKit
import Foundation

class TodoListViewController: UITableViewController
{
    var itemArray = [Item]()
    
    let defaults  = UserDefaults.standard
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loadItems()
    }
    
    //MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done == true ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - Toggle Checkmark
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.reloadData()
    }
    
    //MARK: - Add Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
    {
        var textField = UITextField()
        
        let alert = UIAlertController(
            title: "Add new task",
            message: "Please specify your task",
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default)
        { (addAction) in
            if textField.text != ""
            {
                let newItem = Item()
                newItem.title = textField.text!
                self.itemArray.append(newItem)
                
                self.saveItems()
                
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField
        { (alertTextField) in
            alertTextField.placeholder = "Your task"
            textField = alertTextField
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupilation
    
    func saveItems()
    {
        let encoder = PropertyListEncoder()
        do
        {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        }
        catch
        {
            print("Error while encoding itemArray: \(error)")
        }
    }
    
    func loadItems()
    {
        if let data = try? Data(contentsOf: dataFilePath!)
        {
            let decoder = PropertyListDecoder()
            do
            {
                itemArray = try decoder.decode([Item].self, from: data)
            }
            catch
            {
                print("Error while decoding Items.plist: \(error)")
            }
        }
        
        
    }
}

