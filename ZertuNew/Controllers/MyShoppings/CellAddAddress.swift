//
//  CellAddAddress.swift
//  ZertuNew
//
//  Created by Shalini Sharma on 12/16/21.
//  Copyright © 2021 Shalini Sharma. All rights reserved.
//

import UIKit

class CellAddAddress: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var tf:UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class CellCheckout_Header1: UITableViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    override func awakeFromNib() {super.awakeFromNib()}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}}

class CellCheckout_Header2: UITableViewCell {
    override func awakeFromNib() {super.awakeFromNib()}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}}

class CellCheckout_Rows: UITableViewCell {
    @IBOutlet weak var lbl_1:UILabel!
    @IBOutlet weak var lbl_2:UILabel!
    @IBOutlet weak var lbl_3:UILabel!
    override func awakeFromNib() {super.awakeFromNib()}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}}

class CellCheckout_Total: UITableViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    override func awakeFromNib() {super.awakeFromNib()}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}}

class CellCheckout_Card: UITableViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    override func awakeFromNib() {super.awakeFromNib()}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}}

class CellCheckout_Address: UITableViewCell {
    @IBOutlet weak var lblTitle:UILabel!
    override func awakeFromNib() {super.awakeFromNib()}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}}

