//
//  ViewController.swift
//  Yap
//
//  Created by Ali Barış Gültekin on 25.04.2021.
//

import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController
{
    var selectedCategory: Category?
    {
        didSet
        {
            loadItems()
        }
    }
    
    let realm = try! Realm()
    
    var items: Results<Item>?
        
    @IBOutlet weak var searchBar: UISearchBar!
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchBar.delegate = self
        loadItems()
        title = selectedCategory!.name
    }
    
    //MARK: - Table View Setup
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = items?[indexPath.row]
        {
            cell.textLabel?.text = item.name
            cell.accessoryType = (item.done == true) ? .checkmark : .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let res: CGFloat = UIScreen.main.bounds.height/8
        return res
    }
    
    //MARK: - TableView Actions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let item = items?[indexPath.row]
        {
            do
            {
                try realm.write
                {
                    item.done = !item.done
                }
            }
            catch
            {
                print("--Error toggling done property: \(error)")
            }
            tableView.reloadData()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
                if let currentCategory = self.selectedCategory
                {
                    do
                    {
                        try self.realm.write
                        {
                            let newItem = Item()
                            newItem.name = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    }
                    catch
                    {
                        print("--Error adding item \(error)")
                    }
                }
                
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
    
    //MARK: - CRUD
    func saveItems(item: Item)
    {
        do
        {
            try realm.write
            {
                realm.add(item)
            }
        }
        catch
        {
            print("--saveItems Error: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems()
    {
        items = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    override func deleteItem(at index: Int)
    {
        if let item = items?[index]
        {
            do
            {
                try realm.write
                {
                    realm.delete(item)
                }
            }
            catch
            {
                print("--Error deleting item: \(error)")
            }
        }
    }
}

//MARK: - Search Bar
extension TodoListViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        items = selectedCategory?.items.filter(NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar.text?.count == 0
        {
            DispatchQueue.main.async
            {
                searchBar.resignFirstResponder()
            }
            loadItems()
        }
        else
        {
            items = selectedCategory?.items.filter(NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
    }
}

