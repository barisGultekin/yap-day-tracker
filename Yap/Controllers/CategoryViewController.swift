//
//  CategoryViewController.swift
//  Yap
//
//  Created by Ali Barış Gültekin on 10.05.2021.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController, SwipeTableViewCellDelegate
{
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadCategories()
    }
    
    //MARK: - TableView Actions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow
        {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]?
    {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete")
        { action, indexPath in
            self.deleteCategory(at: indexPath.row)
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
    

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions
    {
        var options = SwipeOptions()
        
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        
        return options
    }

    
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
//    {
//        let deleteAction = UIContextualAction(style: .destructive,
//                                              title: "Delete")
//        { action, view, completionHandler in
//            self.deleteCategory(at: indexPath.row, with: indexPath)
//            completionHandler(true)
//        }
//
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }
    
    // MARK: - TableView Setup
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "CategoryItemCell", for: indexPath) as! SwipeTableViewCell
        
        cell.textLabel?.text = categories?[indexPath.row].name
        
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var res: CGFloat = UIScreen.main.bounds.height/12
        if let sizer = categories?.count
        {
            if sizer > 10
            {
                res = UIScreen.main.bounds.height/CGFloat(sizer)
            }
            if sizer > 16
            {
                res = UIScreen.main.bounds.height/16
            }
        }else
        {
            res = UIScreen.main.bounds.height/12
        }
        return res
    }
    
    //MARK: - Add Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
    {
        var textField = UITextField()
        
        let alert = UIAlertController(
            title: "Create Category",
            message: "Please enter category name",
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add",
                                      style: .default)
        { addAction in
            let newCategory = Category()
            newCategory.name = textField.text!
            
            self.saveCategories(category: newCategory)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
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
    func saveCategories(category: Category)
    {
        do
        {
            try self.realm.write
            {
                realm.add(category)
            }
        }
        catch
        {
            print("--saveCategories Error: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories()
    {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func deleteCategory(at index: Int)
    {
        if let category = categories?[index]
        {
            do
            {
                try realm.write
                {
                    realm.delete(category)
                }
            }
            catch
            {
                print("--Error deleting item: \(error)")
            }
        }
        tableView.reloadData()
    }
}
