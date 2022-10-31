import 'dotenv/config'
import alfy from 'alfy';
import {getSynonyms} from "@sinew/alfi-node";

const [_, __, arg] = process.argv

// Set defaults
const count = arg.match(/\d+/) ? arg.match(/\d+/)[0] : 5;
const word = arg.replace(/\d+/, '').trim()

if(word.replace(' ', '')) {
    const data = await getSynonyms(word, count)

    const items = data.map(element => ({
        title: element,
        subtitle: '',
        arg: element
    }));

    alfy.output(items);
} else {
    alfy.output([{
        title: 'Enter the word',
        subtitle: 'syn {count: number} {word: string}. I.e syn 10 beautiful',
        arg: ''
    }])
}