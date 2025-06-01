import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";

const students = [
  {
    address: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", // Local Account
  },
  {
    address: "0x952a13Af11dE40B7E6915fe71B02a888E09034D5", // Sepolia Account
  },
];

let studentsData = students.map((user) => {
  return [user.address];
});

let tree = StandardMerkleTree.of(studentsData, ["address"]);

let data = Array.from(tree.entries()).map((item, index) => {
  return {
    address: item[1][0],
    proof: tree.getProof(item[0]),
  };
});

let fileContent = {
  root: tree.root,
  data: data,
};

fs.writeFileSync("merkle_data.json", JSON.stringify(fileContent, null, 2));
