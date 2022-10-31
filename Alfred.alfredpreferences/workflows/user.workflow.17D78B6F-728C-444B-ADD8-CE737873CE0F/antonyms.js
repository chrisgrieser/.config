import alfy from 'alfy';
import {getAntonyms} from "@sinew/alfi-node";

const [_, __, arg] = process.argv

// Set defaults
const count = arg.match(/\d+/) ? arg.match(/\d+/)[0] : 5;
const word = arg.replace(/\d+/, '').trim()

if(word.replace(' ', '')) {
    const data = await getAntonyms(word, count)

    const items = data.map(element => ({
        title: element,
        subtitle: '',
        arg: element
    }));

    alfy.output(items);
} else {
    alfy.output([{
        title: 'Enter the word',
        subtitle: 'ant {count: number} {word: string}. I.e syn 10 beautiful',
        arg: ''
    }])
}